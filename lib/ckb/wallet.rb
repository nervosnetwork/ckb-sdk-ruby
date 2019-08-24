# frozen_string_literal: true

module CKB
  DAO_LOCK_PERIOD_BLOCKS = 10
  DAO_MATURITY_BLOCKS = 5

  class Wallet
    attr_reader :api
    attr_reader :key
    attr_reader :pubkey
    attr_reader :addr
    attr_reader :address
    attr_reader :hash_type

    attr_accessor :skip_data_and_type

    # @param api [CKB::API]
    # @param key [CKB::Key | String] Key or pubkey
    def initialize(api, key, skip_data_and_type: true, hash_type: "type")
      @api = api
      if key.is_a?(CKB::Key)
        @key = key
        @pubkey = @key.pubkey
      else
        @pubkey = key
        @key = nil
      end
      @addr = Address.from_pubkey(@pubkey)
      @address = @addr.to_s
      @skip_data_and_type = skip_data_and_type
      raise "Wrong hash_type, hash_type should be `data` or `type`" unless %w(data type).include?(hash_type)

      @hash_type = hash_type
    end

    def self.from_hex(api, privkey, hash_type: "type")
      new(api, Key.new(privkey), hash_type: hash_type)
    end

    def hash_type=(hash_type)
      @lock_hash = nil
      @hash_type = hash_type
    end

    # @return [CKB::Types::Output[]]
    def get_unspent_cells
      to = api.get_tip_block_number.to_i
      results = []
      current_from = 0
      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = api.get_cells_by_lock_hash(lock_hash, current_from.to_s, current_to.to_s)
        if skip_data_and_type
          cells.each do |cell|
            output = api.get_live_cell(cell.out_point).cell
            results << cell if (output.data.nil? || output.data == "0x") && output.type.nil?
          end
        else
          results.concat(cells)
        end
        current_from = current_to + 1
      end
      results
    end

    def get_balance
      get_unspent_cells.map { |cell| cell.capacity.to_i }.reduce(0, &:+)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String ] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def generate_tx(target_address, capacity, data = "0x", key: nil, fee: 0)
      key = get_key(key)

      output = Types::Output.new(
        capacity: capacity,
        data: data,
        lock: Types::Script.generate_lock(
          addr.parse(target_address),
          api.secp_cell_type_hash,
          "type"
        )
      )

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )

      i = gather_inputs(
        capacity,
        output.calculate_min_capacity,
        change_output.calculate_min_capacity,
        fee
      )
      input_capacities = i.capacities

      outputs = [output]
      change_output.capacity = input_capacities - (capacity + fee)
      outputs << change_output if change_output.capacity.to_i > 0

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
        ],
        inputs: i.inputs,
        outputs: outputs,
        outputs_data: outputs.map(&:data),
        witnesses: i.witnesses
      )

      tx_hash = api.compute_transaction_hash(tx)

      tx.sign(key, tx_hash)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def send_capacity(target_address, capacity, data = "0x", key: nil, fee: 0)
      tx = generate_tx(target_address, capacity, data, key: key, fee: fee)
      send_transaction(tx)
    end

    # @param capacity [Integer]
    # @param key [CKB::Key | String] Key or private key hex string
    #
    # @return [CKB::Type::OutPoint]
    def deposit_to_dao(capacity, key: nil)
      key = get_key(key)

      output = Types::Output.new(
        capacity: capacity,
        lock: Types::Script.generate_lock(addr.blake160, code_hash, hash_type),
        type: Types::Script.new(
          code_hash: api.dao_code_hash,
          args: []
        )
      )

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )

      i = gather_inputs(
        capacity,
        output.calculate_min_capacity,
        change_output.calculate_min_capacity,
        0
      )
      input_capacities = i.capacities

      outputs = [output]
      change_output.capacity = input_capacities - capacity
      outputs << change_output if change_output.capacity.to_i > 0

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group"),
          Types::CellDep.new(out_point: api.dao_out_point)
        ],
        inputs: i.inputs,
        outputs: outputs,
        outputs_data: outputs.map(&:data),
        witnesses: i.witnesses
      )

      tx_hash = api.compute_transaction_hash(tx)
      send_transaction(tx.sign(key, tx_hash))

      Types::OutPoint.new(tx_hash: tx_hash, index: 0)
    end

    # @param out_point [CKB::Type::OutPoint]
    # @param key [CKB::Key | String] Key or private key hex string
    #
    # @return [CKB::Type::Transaction]
    def generate_withdraw_from_dao_transaction(out_point, key: nil)
      key = get_key(key)

      cell_status = api.get_live_cell(out_point)
      unless cell_status.status == "live"
        raise "Cell is not yet live!"
      end
      tx = api.get_transaction(out_point.tx_hash)
      unless tx.tx_status.status == "committed"
        raise "Transaction is not commtted yet!"
      end
      deposit_block = api.get_block(tx.tx_status.block_hash).header
      deposit_block_number = deposit_block.number.to_i
      current_block = api.get_tip_header
      current_block_number = current_block.number.to_i

      if deposit_block_number == current_block_number
        raise "You need to at least wait for 1 block before generating DAO withdraw transaction!"
      end

      windowleft = DAO_LOCK_PERIOD_BLOCKS - (current_block_number - deposit_block_number) % DAO_LOCK_PERIOD_BLOCKS
      windowleft = DAO_MATURITY_BLOCKS if windowleft < DAO_MATURITY_BLOCKS
      since = current_block_number + windowleft + 1

      output_capacity = api.calculate_dao_maximum_withdraw(out_point, current_block.hash).to_i

      dup_out_point = out_point.dup
      new_out_point = Types::OutPoint.new(
        tx_hash: dup_out_point.tx_hash,
        index: dup_out_point.index
      )

      outputs = [
        Types::Output.new(capacity: output_capacity, lock: lock)
      ]
      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [
          Types::CellDep.new(out_point: api.dao_out_point),
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
        ],
        header_deps: [
          current_block.hash,
          deposit_block.hash
        ],
        inputs: [
          Types::Input.new(previous_output: new_out_point, since: since)
        ],
        outputs: outputs,
        outputs_data: outputs.map(&:data),
        witnesses: [
          Types::Witness.new(data: ["0x0000000000000000"])
        ]
      )
      tx_hash = api.compute_transaction_hash(tx)
      tx.sign(key, tx_hash)
    end

    # @param hash_hex [String] "0x..."
    #
    # @return [CKB::Types::Transaction]
    def get_transaction(hash)
      api.get_transaction(hash)
    end

    def block_assembler_config
      %(
[block_assembler]
code_hash = "#{lock.code_hash}"
args = #{lock.args}
     ).strip
    end

    def lock_hash
      @lock_hash ||= lock.to_hash(api)
    end

    # @return [CKB::Types::Script]
    def lock
      Types::Script.generate_lock(
        addr.blake160,
        code_hash,
        hash_type
      )
    end

    private

    # @param transaction [CKB::Transaction]
    def send_transaction(transaction)
      api.send_transaction(transaction)
    end

    # @param capacity [Integer]
    # @param min_capacity [Integer]
    # @param min_change_capacity [Integer]
    # @param fee [Integer]
    def gather_inputs(capacity, min_capacity, min_change_capacity, fee)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      total_capacities = capacity + fee
      input_capacities = 0
      inputs = []
      witnesses = []
      get_unspent_cells.each do |cell|
        input = Types::Input.new(
          previous_output: cell.out_point,
          since: "0"
        )
        inputs << input
        witnesses << Types::Witness.new(data: [])
        input_capacities += cell.capacity.to_i

        diff = input_capacities - total_capacities
        break if diff >= min_change_capacity || diff.zero?
      end

      raise "Capacity not enough!" if input_capacities < total_capacities

      OpenStruct.new(inputs: inputs, capacities: input_capacities, witnesses: witnesses)
    end

    def code_hash
      hash_type == "data" ? api.secp_cell_code_hash : api.secp_cell_type_hash
    end

    # @param [CKB::Key | String | nil]
    #
    # @return [CKB::Key]
    def get_key(key)
      raise "Must provide a private key" unless @key || key

      return @key if @key

      the_key = convert_key(key)
      raise "Key not match pubkey" unless the_key.pubkey == @pubkey

      the_key
    end

    # @param key [CKB::Key | String] a Key or private key hex string
    #
    # @return [CKB::Key]
    def convert_key(key)
      return if key.nil?

      return key if key.is_a?(CKB::Key)

      CKB::Key.new(key)
    end
  end
end
