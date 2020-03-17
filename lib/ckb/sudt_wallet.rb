module CKB
  class SUDTWallet
    SUDT_CODE_HASH = "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212"
    SUDT_OUT_POINT_TX_HASH = "0xa608b247bf322474f0b9cb3b6928eff08ecffac658724bcae4611a37d0da7218"
    EVERYONE_CAN_PAY_CODE_HAHS= "0xed9d2fd9969979f44b9686645099781279c26a7bef358d8f2e75a71de161b1e2"
    attr_reader :api, :key, :blake160, :address, :sudt_type_script_cell_dep, :sudt_out_point, :min_capacity, :min_amount, :anyone_can_pay_address

    def initialize(api:, key:, mode: MODE::TESTNET, min_capacity: nil, min_amount: nil)
      @api = api
      @min_capacity = min_capacity
      @min_amount = min_amount
      if key.is_a?(CKB::Key)
        @key = key
        @pubkey = @key.pubkey
      else
        @pubkey = key
        @key = nil
      end
      @blake160 = CKB::Key.blake160(@pubkey)
      @address = Address.new(lock, mode: mode).to_s
      @anyone_can_pay_address = Address.new(anyone_can_pay_lock, mode: mode).to_s
      ## TODO need change to production config
      @sudt_out_point = Types::OutPoint.new(tx_hash: SUDT_OUT_POINT_TX_HASH, index: 0)
      @sudt_type_script_cell_dep = Types::CellDep.new(out_point: @sudt_out_point)
    end

    def self.from_hex(api, privkey, mode: MODE::TESTNET)
      new(api: api, key: Key.new(privkey), mode: mode)
    end

    def issue(amount, outputs_validator: nil)
      fee = CKB::Utils.byte_to_shannon(0.01).to_i
      hex_amount = generate_udt_cell_data(amount)
      tx = generate_issue_tx(hex_amount, fee: fee)
      api.send_transaction(tx, outputs_validator)
    end

    def transfer(target_address, amount, type_hash:, fee: 0, outputs_validator: nil)
      tx = generate_transfer_tx(target_address, amount, fee, type_hash)
      api.send_transaction(tx, outputs_validator)
    end

    def burn(amount, type_hash:, outputs_validator: nil, fee: 0)
      tx = generate_burn_tx(type_hash, amount, fee)
      api.send_transaction(tx, outputs_validator)
    end

    def balance(type_hash)
      get_unspent_sudt_cells(type_hash)[:amounts]
    end

    private

    def generate_burn_tx(type_hash, amount, fee, use_dep_group: true)
      min_capacity = CKB::Utils.byte_to_shannon(150)
      key = get_key(key)
      parsed_address = AddressParser.new(address).parse
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"
      raise "Amount not enough!" if balance(type_hash) < amount

      output = Types::Output.new(capacity: min_capacity, lock: parsed_address.script, type: sudt_type_script)

      output_data = generate_udt_cell_data(balance(type_hash) - amount)
      change_output = Types::Output.new(
        capacity: 0,
        lock: lock,
      )
      change_output_data = "0x#{'0' * 32}"
      result = gather_sudt_inputs(min_capacity, change_output.calculate_min_capacity(change_output_data), fee, type_hash, need_amounts: balance(type_hash))
      input_capacities = result.capacities
      input_amounts = result.amounts
      outputs = [output]
      outputs_data = [output_data]
      change_output.capacity = input_capacities - (min_capacity + fee)
      if change_output.capacity.to_i > 0
        outputs << change_output
        if input_amounts > amount
          change_output.type = sudt_type_script
        else
          change_output_data = "0x"
        end
        outputs_data << change_output_data
      end

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [],
        inputs: result.inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: result.witnesses
      )

      if use_dep_group
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
      else
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_code_out_point, dep_type: "code")
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_data_out_point, dep_type: "code")
      end
      tx.cell_deps << sudt_type_script_cell_dep

      tx.sign(key)
    end

    def generate_transfer_tx(target_address, amount, fee, type_hash, use_dep_group: true)
      min_capacity = CKB::Utils.byte_to_shannon(150)
      key = get_key(key)
      parsed_address = AddressParser.new(target_address).parse
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"

      output = Types::Output.new(capacity: min_capacity, lock: parsed_address.script, type: sudt_type_script)
      output_data = generate_udt_cell_data(amount)
      capacity_change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )
      amount_change_output = Types::Output.new(
        capacity: min_capacity,
        lock: lock,
        type: sudt_type_script
      )
      capacity_change_output_data = "0x"
      amount_change_output_data = "0x#{'0' * 32}"
      result = gather_sudt_inputs(min_capacity, capacity_change_output.calculate_min_capacity(capacity_change_output_data), fee, type_hash, need_amounts: amount)
      input_capacities = result.capacities
      input_amounts = result.amounts
      outputs = [output]
      outputs_data = [output_data]
      capacity_change_output.capacity = input_capacities - (min_capacity + fee) - min_capacity
      if capacity_change_output.capacity.to_i > 0
        outputs << capacity_change_output
        outputs_data << capacity_change_output_data
      end
      if input_amounts > amount
        change_output_data = generate_udt_cell_data(input_amounts - amount)
        amount_change_output_data = change_output_data
        outputs << amount_change_output
        outputs_data << amount_change_output_data
      end

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [],
        inputs: result.inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: result.witnesses
      )

      if use_dep_group
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
      else
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_code_out_point, dep_type: "code")
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_data_out_point, dep_type: "code")
      end
      tx.cell_deps << sudt_type_script_cell_dep

      tx.sign(key)
    end

    def generate_issue_tx(data = "0x", key: nil, fee: 0, use_dep_group: true)
      capacity = CKB::Utils.byte_to_shannon(150)
      target_address = address
      key = get_key(key)
      parsed_address = AddressParser.new(target_address).parse
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"

      output = Types::Output.new(
        capacity: capacity,
        lock: parsed_address.script,
        type: sudt_type_script
      )
      output_data = data

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )
      change_output_data = "0x"

      i = gather_inputs(
        capacity,
        output.calculate_min_capacity(output_data),
        change_output.calculate_min_capacity(change_output_data),
        fee
      )
      input_capacities = i.capacities

      outputs = [output]
      outputs_data = [output_data]
      change_output.capacity = input_capacities - (capacity + fee)
      if change_output.capacity.to_i > 0
        outputs << change_output
        outputs_data << change_output_data
      end

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [],
        inputs: i.inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: i.witnesses
      )

      if use_dep_group
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
      else
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_code_out_point, dep_type: "code")
        tx.cell_deps << Types::CellDep.new(out_point: api.secp_data_out_point, dep_type: "code")
      end
      tx.cell_deps << sudt_type_script_cell_dep
      tx.sign(key)
    end

    def gather_inputs(capacity, min_capacity, min_change_capacity, fee)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity
      CellCollector.new(
        api,
        skip_data_and_type: true
      ).gather_inputs(
        [lock_hash],
        capacity,
        min_change_capacity,
        fee
      )
    end

    def gather_sudt_inputs(capacity, min_change_capacity, fee, type_hash, need_amounts: nil)
      total_capacities = capacity + min_change_capacity + fee
      input_capacities = 0
      inputs = []
      witnesses = []
      result = get_unspent_sudt_cells(type_hash, need_amounts, total_capacities)
      result[:outputs].each do |output|
        input = Types::Input.new(
          previous_output: output.out_point,
          since: 0
        )
        inputs << input
        witnesses << CKB::Types::Witness.new
        input_capacities += output.capacity.to_i
      end
      raise "Capacity not enough!" if input_capacities < total_capacities
      raise "Amount not enough!" if result[:amounts] < need_amounts

      witnesses[0].lock = "0x#{'0' * 130}"

      OpenStruct.new(
        inputs: inputs,
        capacities: input_capacities,
        amounts: result[:amounts],
        witnesses: witnesses
      )
    end

    def get_unspent_sudt_cells(type_hash = nil, need_amounts = nil, need_capacities = nil)
      raise "type_hash can't be empty" if type_hash.nil? || type_hash.empty?

      to = api.get_tip_block_number.to_i
      results = []
      total_amount = 0
      total_capacities = 0
      current_from = 0
      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = api.get_cells_by_lock_hash(lock_hash, current_from, current_to)
        cells.each do |cell|
          next if cell.out_point.to_h == sudt_out_point.to_h

          if cell.type && cell.type.code_hash == SUDT_CODE_HASH && cell.type.compute_hash == type_hash
            live_cell = api.get_live_cell(cell.out_point, true)
            total_amount += parse_udt_cell_data(live_cell.cell.data.content)
            results << cell
            total_capacities += cell.capacity
            break if need_amounts && total_amount >= need_amounts
          end
        end

        current_from = current_to + 1
      end
      if need_capacities && total_capacities < need_capacities
        current_from = 0
        while current_from <= to
          current_to = [current_from + 100, to].min
          cells = api.get_cells_by_lock_hash(lock_hash, current_from, current_to)
          cells.each do |cell|
            next if cell.type || cell.output_data_len > 0

            results << cell
            total_capacities += cell.capacity
            break if need_capacities && total_capacities >= need_capacities
          end

          current_from = current_to + 1
        end
      end
      {
        outputs: results,
        capacities: total_capacities,
        amounts: total_amount
      }
    end

    def anyone_can_pay_lock
      pubkey_hash = blake160
      if min_capacity
        pubkey_hash = CKB::Utils.hex_concat(blake160, [min_capacity].pack("C"))
      end
      if min_amount
        pubkey_hash = CKB::Utils.hex_concat(blake160, [min_amount].pack("C"))
      end
      Types::Script.generate_lock(
        pubkey_hash,
        EVERYONE_CAN_PAY_CODE_HAHS
      )
    end

    def lock
      Types::Script.generate_lock(
        blake160,
        SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
      )
    end

    def lock_hash
      @lock_hash ||=
        begin
          if min_capacity
            anyone_can_pay_lock.compute_hash
          else
            lock.compute_hash
          end
        end
    end

    def get_key(key)
      raise "Must provide a private key" unless @key || key

      return @key if @key

      the_key = convert_key(key)
      raise "Key not match pubkey" unless the_key.pubkey == @pubkey

      the_key
    end

    def sudt_type_script
      ## TODO hash_type will change to type
      Types::Script.new(code_hash: SUDT_CODE_HASH, args: lock_hash, hash_type: "data")
    end

    def parse_udt_cell_data(data)
      return if data == "0x"
      CKB::Utils.hex_to_bin(data).reverse.unpack1("B*").to_i(2)
    end

    def generate_udt_cell_data(amount)
      "0x#{[amount.to_s(2).rjust(128, "0")].pack("B*").reverse.unpack("H*")[0]}"
    end
  end
end
