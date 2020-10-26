# frozen_string_literal: true

module CKB
  DAO_LOCK_PERIOD_EPOCHS = 180
  DAO_MATURITY_BLOCKS = 5

  class Wallet
    attr_reader :api, :key, :pubkey, :address, :hash_type, :blake160, :indexer_api

    attr_accessor :skip_data_and_type

    # @param api [CKB::API]
    # @param key [CKB::Key | String] Key or pubkey
    def initialize(api, key, skip_data_and_type: true, hash_type: "type", mode: MODE::TESTNET, indexer_api: nil)
      raise "Wrong hash_type, hash_type should be `data` or `type`" unless CKB::ScriptHashType::TYPES.include?(hash_type)

      @api = api
      if key.is_a?(CKB::Key)
        @key = key
        @pubkey = @key.pubkey
      else
        @pubkey = key
        @key = nil
      end
      @hash_type = hash_type
      @blake160 = CKB::Key.blake160(@pubkey)
      @addr = Address.new(lock, mode: mode)
      @address = @addr.to_s
      @skip_data_and_type = skip_data_and_type
      @indexer_api = indexer_api
    end

    def self.from_hex(api, privkey, hash_type: "type", skip_data_and_type: true, mode: MODE::TESTNET, indexer_api: nil)
      new(api, Key.new(privkey), hash_type: hash_type, skip_data_and_type: skip_data_and_type, mode: mode, indexer_api: indexer_api)
    end

    def hash_type=(hash_type)
      @lock_hash = nil
      @hash_type = hash_type
    end

    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    # @return [CKB::Types::Output[]]
    def get_unspent_cells(need_capacities: nil)
      CellCollector.new(
        indexer_api,
        skip_data_and_type: @skip_data_and_type
      ).get_unspent_cells(
        search_key: search_key,
        need_capacities: need_capacities
      )[:outputs]
    end

    def get_balance
      CellCollector.new(
        indexer_api,
        skip_data_and_type: @skip_data_and_type,
      ).get_unspent_cells(
        search_key: search_key,
      )[:total_capacities]
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String ] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def generate_tx(target_address, capacity, data = "0x", key: nil, fee: 0, use_dep_group: true, from_block_number: 0)
      key = get_key(key)
      parsed_address = AddressParser.new(target_address).parse
      raise "Right now only supports sending to default single signed lock!" if parsed_address.address_type == "SHORTMULTISIG"

      output = Types::Output.new(
        capacity: capacity,
        lock: parsed_address.script
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
        from_block_number: from_block_number
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

      tx.sign(key)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def send_capacity(target_address, capacity, data = "0x", key: nil, fee: 0, outputs_validator: "default", from_block_number: 0)
      tx = generate_tx(target_address, capacity, data, key: key, fee: fee, from_block_number: from_block_number)
      send_transaction(tx, outputs_validator)
    end

    # @param capacity [Integer]
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer]
    #
    # @return [CKB::Type::OutPoint]
    def deposit_to_dao(capacity, key: nil, fee: 0)
      key = get_key(key)

      output = Types::Output.new(
        capacity: capacity,
        lock: Types::Script.generate_lock(blake160, code_hash, hash_type),
        type: Types::Script.new(
          code_hash: api.dao_type_hash,
          args: "0x",
          hash_type: "type"
        )
      )
      output_data = "0x0000000000000000"

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
        cell_deps: [
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group"),
          Types::CellDep.new(out_point: api.dao_out_point)
        ],
        inputs: i.inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: i.witnesses
      )

      tx_hash = tx.compute_hash
      send_transaction(tx.sign(key))

      Types::OutPoint.new(tx_hash: tx_hash, index: 0)
    end

    def start_withdrawing_from_dao(out_point, key: nil, fee: 0)
      key = get_key(key)

      cell_status = api.get_live_cell(out_point)
      raise "Cell is not yet live!" unless cell_status.status == "live"

      tx = api.get_transaction(out_point.tx_hash)
      raise "Transaction is not commtted yet!" unless tx.tx_status.status == "committed"

      deposit_block = api.get_block(tx.tx_status.block_hash).header
      deposit_block_number = deposit_block.number

      output = cell_status.cell.output.dup
      output_data = CKB::Utils.bin_to_hex([deposit_block_number].pack("Q<"))

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )
      change_output_data = "0x"

      i = gather_inputs(
        0,
        0,
        change_output.calculate_min_capacity(change_output_data),
        fee
      )

      outputs = [output]
      outputs_data = [output_data]

      change_output.capacity = i.capacities - fee
      if change_output.capacity.to_i > 0
        outputs << change_output
        outputs_data << change_output_data
      end

      inputs = [Types::Input.new(previous_output: out_point.dup)] + i.inputs
      witnesses = [Types::Witness.new] + i.witnesses

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group"),
          Types::CellDep.new(out_point: api.dao_out_point)
        ],
        header_deps: [
          deposit_block.hash
        ],
        inputs: inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: witnesses
      )

      tx_hash = tx.compute_hash
      send_transaction(tx.sign(key))

      Types::OutPoint.new(tx_hash: tx_hash, index: 0)
    end

    # @param deposit_out_point [CKB::Type::OutPoint]
    # @param withdrawing_out_point [CKB::Type::OutPoint]
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer]
    #
    # @return [CKB::Type::Transaction]
    def generate_withdraw_from_dao_transaction(deposit_out_point, withdrawing_out_point, key: nil, fee: 0)
      key = get_key(key)

      cell_status = api.get_live_cell(withdrawing_out_point, true)
      raise "Cell is not yet live!" unless cell_status.status == "live"

      tx = api.get_transaction(withdrawing_out_point.tx_hash)
      raise "Transaction is not commtted yet!" unless tx.tx_status.status == "committed"

      deposit_block_number = CKB::Utils.hex_to_bin(cell_status.cell.data.content).unpack("Q<")[0]
      deposit_block = api.get_block_by_number(deposit_block_number).header
      deposit_epoch = self.class.parse_epoch(deposit_block.epoch)

      withdraw_block = api.get_block(tx.tx_status.block_hash).header
      withdraw_epoch = self.class.parse_epoch(withdraw_block.epoch)

      withdraw_fraction = withdraw_epoch.index * deposit_epoch.length
      deposit_fraction = deposit_epoch.index * withdraw_epoch.length
      deposited_epoches = withdraw_epoch.number - deposit_epoch.number
      deposited_epoches += 1 if withdraw_fraction > deposit_fraction
      lock_epochs = (deposited_epoches + (DAO_LOCK_PERIOD_EPOCHS - 1)) / DAO_LOCK_PERIOD_EPOCHS * DAO_LOCK_PERIOD_EPOCHS
      minimal_since_epoch_number = deposit_epoch.number + lock_epochs
      minimal_since_epoch_index = deposit_epoch.index
      minimal_since_epoch_length = deposit_epoch.length

      minimal_since = self.class.epoch_since(minimal_since_epoch_length, minimal_since_epoch_index, minimal_since_epoch_number)

      # a hex string
      output_capacity = api.calculate_dao_maximum_withdraw(deposit_out_point.dup, withdraw_block.hash).hex

      outputs = [
        Types::Output.new(capacity: output_capacity - fee, lock: lock)
      ]
      outputs_data = ["0x"]
      tx = Types::Transaction.new(
        version: 0,
        cell_deps: [
          Types::CellDep.new(out_point: api.dao_out_point),
          Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
        ],
        header_deps: [
          deposit_block.hash,
          withdraw_block.hash
        ],
        inputs: [
          Types::Input.new(previous_output: withdrawing_out_point.dup, since: minimal_since)
        ],
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: [
          Types::Witness.new(input_type: "0x0000000000000000")
        ]
      )
      tx.sign(key)
    end

    # @param epoch [Integer]
    def self.parse_epoch(epoch)
      OpenStruct.new(
        length: (epoch >> 40) & 0xFFFF,
        index: (epoch >> 24) & 0xFFFF,
        number: epoch & 0xFFFFFF
      )
    end

    def self.epoch_since(length, index, number)
      (0x20 << 56) + (length << 40) + (index << 24) + number
    end

    # @param hash [String] "0x..."
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
      @lock_hash ||= lock.compute_hash
    end

    # @return [CKB::Types::Script]
    def lock
      Types::Script.generate_lock(
        blake160,
        code_hash,
        hash_type
      )
    end

    private

    # @param transaction [CKB::Transaction]
    def send_transaction(transaction, outputs_validator = "default")
      api.send_transaction(transaction, outputs_validator)
    end

    # @param capacity [Integer]
    # @param min_capacity [Integer]
    # @param min_change_capacity [Integer]
    # @param fee [Integer]
    def gather_inputs(capacity, min_capacity, min_change_capacity, fee, from_block_number: 0)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      CellCollector.new(
        indexer_api,
        skip_data_and_type: @skip_data_and_type,
      ).gather_inputs(
        [search_key],
        capacity,
        min_change_capacity,
        fee
      )
    end

    def code_hash
      hash_type == "data" ? SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_DATA_HASH : SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
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

    def search_key
      @search_key ||= CKB::Indexer::Types::SearchKey.new(lock, "lock")
    end
  end
end
