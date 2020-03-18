module CKB
  class SUDTWallet
    SUDT_CODE_HASH = "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212"
    SUDT_OUT_POINT_TX_HASH = "0x78fbb1d420d242295f8668cb5cf38869adac3500f6d4ce18583ed42ff348fa64"

    attr_reader :api, :key, :blake160, :address, :sudt_type_script_cell_dep, :sudt_out_point

    def initialize(api:, key:, mode: MODE::TESTNET)
      @api = api
      if key.is_a?(CKB::Key)
        @key = key
        @pubkey = @key.pubkey
      else
        @pubkey = key
        @key = nil
      end
      @blake160 = CKB::Key.blake160(@pubkey)
      @address = Address.new(lock, mode: mode).to_s
      ## TODO need change to production config
      @sudt_out_point = Types::OutPoint.new(tx_hash: SUDT_OUT_POINT_TX_HASH, index: 0)
      @sudt_type_script_cell_dep = Types::CellDep.new(out_point: @sudt_out_point)
    end

    def self.from_hex(api, privkey, mode: MODE::TESTNET)
      new(api: api, key: Key.new(privkey), mode: mode)
    end

    def issue(amount, outputs_validator: nil, from_block_number: 0)
      fee = CKB::Utils.byte_to_shannon(0.01).to_i
      hex_amount = generate_udt_cell_data(amount)
      tx = generate_issue_tx(hex_amount, fee: fee, from_block_number: from_block_number)
      api.send_transaction(tx, outputs_validator)
    end

    def transfer(target_address, amount, sudt_type_script:, fee: 0, outputs_validator: nil, from_block_number: 0)
      tx = generate_transfer_tx(target_address, amount, fee, sudt_type_script, from_block_number: from_block_number)
      api.send_transaction(tx, outputs_validator)
    end

    def burn(amount, sudt_type_script:, outputs_validator: nil, fee: 0, from_block_number: 0)
      tx = generate_burn_tx(sudt_type_script, amount, fee, from_block_number: from_block_number)
      api.send_transaction(tx, outputs_validator)
    end

    def balance(sudt_type_script, from_block_number = 0)
      get_unspent_sudt_cells(sudt_type_script: sudt_type_script, from_block_number: from_block_number)[:amounts]
    end

    private

    def generate_burn_tx(sudt_type_script, amount, fee, use_dep_group: true, from_block_number: 0)
      min_capacity = CKB::Utils.byte_to_shannon(150)
      key = get_key(key)
      parsed_address = AddressParser.new(address).parse
      balance = balance(sudt_type_script, from_block_number)
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"
      raise "Amount not enough!" if balance < amount

      output = Types::Output.new(capacity: min_capacity, lock: parsed_address.script, type: sudt_type_script)
      amount_after_burn = balance - amount
      output_data = generate_udt_cell_data(amount_after_burn)
      change_output = Types::Output.new(
        capacity: 0,
        lock: lock,
      )
      change_output_data = "0x"
      result = gather_sudt_inputs(min_capacity, change_output.calculate_min_capacity(change_output_data), fee, sudt_type_script, need_amounts: balance, from_block_number: from_block_number)
      input_capacities = result.capacities
      outputs = [output]
      outputs_data = [output_data]
      change_output.capacity = input_capacities - (min_capacity + fee)
      if change_output.capacity.to_i > 0
        outputs << change_output
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

    def generate_transfer_tx(target_address, amount, fee, sudt_type_script, use_dep_group: true, from_block_number: 0)
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
      result = gather_sudt_inputs(min_capacity, capacity_change_output.calculate_min_capacity(capacity_change_output_data), fee, sudt_type_script, need_amounts: amount, from_block_number: from_block_number)
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

    def generate_issue_tx(data = "0x", key: nil, fee: 0, use_dep_group: true, from_block_number: 0)
      capacity = CKB::Utils.byte_to_shannon(150)
      target_address = address
      key = get_key(key)
      parsed_address = AddressParser.new(target_address).parse
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"

      output = Types::Output.new(
        capacity: capacity,
        lock: parsed_address.script,
        type: sudt_type_script_owned_by_current_address
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
        fee,
        from_block_number
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

    def gather_inputs(capacity, min_capacity, min_change_capacity, fee, from_block_number)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity
      CellCollector.new(
        api,
        skip_data_and_type: true,
        from_block_number: from_block_number
      ).gather_inputs(
        [lock_hash],
        capacity,
        min_change_capacity,
        fee
      )
    end

    def gather_sudt_inputs(capacity, min_change_capacity, fee, sudt_type_script, need_amounts: nil, from_block_number: 0)
      total_capacities = capacity + min_change_capacity + fee
      input_capacities = 0
      inputs = []
      witnesses = []
      result = get_unspent_sudt_cells(sudt_type_script: sudt_type_script, need_amounts: need_amounts, need_capacities: total_capacities, from_block_number: from_block_number)
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

    def get_unspent_sudt_cells(sudt_type_script: nil, need_amounts: nil, need_capacities: nil, from_block_number: 0)
      raise "type script can't be empty" if sudt_type_script.nil? || !sudt_type_script.kind_of?(CKB::Types::Script)

      to = api.get_tip_block_number.to_i
      results = []
      total_amount = 0
      total_capacities = 0
      current_from = from_block_number
      type_hash = sudt_type_script.compute_hash

      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = api.get_cells_by_lock_hash(lock_hash, current_from, current_to)
        cells.each do |cell|
          next if cell.out_point.to_h == sudt_out_point.to_h

          if cell.type && cell.type.code_hash == sudt_type_script.code_hash && cell.type.compute_hash == type_hash
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
        current_from = from_block_number
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

    def lock
      Types::Script.generate_lock(
        blake160,
        SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
      )
    end

    def lock_hash
      @lock_hash ||= lock.compute_hash
    end

    def get_key(key)
      raise "Must provide a private key" unless @key || key

      return @key if @key

      the_key = convert_key(key)
      raise "Key not match pubkey" unless the_key.pubkey == @pubkey

      the_key
    end

    def sudt_type_script_owned_by_current_address
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
