# frozen_string_literal: true
require "bigdecimal"

module CKB
  DAO_LOCK_PERIOD_EPOCHS = 180
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

    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    # @return [CKB::Types::Output[]]
    def get_unspent_cells(need_capacities: nil)
      CellCollector.new(
        @api,
        skip_data_and_type: @skip_data_and_type,
        hash_type: @hash_type
      ).get_unspent_cells(
        lock_hash,
        need_capacities: need_capacities
      )[:outputs]
    end

    def get_balance
      CellCollector.new(
        @api,
        skip_data_and_type: @skip_data_and_type,
        hash_type: @hash_type
      ).get_unspent_cells(
        lock_hash
      )[:total_capacities]
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String ] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def generate_tx(target_address, capacity, data = "0x", key: nil, fee_rate: 0, use_dep_group: true)
      key = get_key(key)

      cell_deps = []
      if use_dep_group
        cell_deps << Types::CellDep.new(out_point: api.secp_group_out_point, dep_type: "dep_group")
      else
        cell_deps << Types::CellDep.new(out_point: api.secp_code_out_point, dep_type: "code")
        cell_deps << Types::CellDep.new(out_point: api.secp_data_out_point, dep_type: "code")
      end

      tx_size = TransactionSize.base_size + TransactionSize.every_cell_dep * cell_deps.size

      output = Types::Output.new(
        capacity: capacity,
        lock: Types::Script.generate_lock(
          addr.parse(target_address),
          api.secp_cell_type_hash,
          "type"
        )
      )
      output_data = data
      tx_size += TransactionSize.every_output(output)
      tx_size += TransactionSize.every_outputs_data(data)

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )
      change_output_data = "0x"
      tx_size += TransactionSize.every_output(change_output)
      tx_size += TransactionSize.every_outputs_data(change_output_data)

      i = gather_inputs(
        capacity + tx_size * fee_rate / BigDecimal(1000),
        output.calculate_min_capacity(output_data),
        change_output.calculate_min_capacity(change_output_data),
        fee_rate
      )
      input_capacities = i.capacities

      outputs = [output]
      outputs_data = [output_data]
      change_output.capacity = (input_capacities - (capacity + tx_size * fee_rate / BigDecimal(1000) + i.need_fee)).floor
      if change_output.capacity.to_i > 0
        outputs << change_output
        outputs_data << change_output_data
      end

      tx = Types::Transaction.new(
        version: 0,
        cell_deps: cell_deps,
        inputs: i.inputs,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: i.witnesses
      )

      tx.sign(key, tx.compute_hash)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String] "0x..."
    # @param key [CKB::Key | String] Key or private key hex string
    # @param fee [Integer] transaction fee, in shannon
    def send_capacity(target_address, capacity, data = "0x", key: nil, fee_rate: 0)
      tx = generate_tx(target_address, capacity, data, key: key, fee_rate: fee_rate)
      send_transaction(tx)
    end

    # @param capacity [Integer]
    # @param key [CKB::Key | String] Key or private key hex string
    #
    # @return [CKB::Type::OutPoint]
    def deposit_to_dao(capacity, key: nil, fee_rate: 0)
      key = get_key(key)

      tx_size = TransactionSize.base_size + TransactionSize.every_cell_dep * 2

      output = Types::Output.new(
        capacity: capacity,
        lock: Types::Script.generate_lock(addr.blake160, code_hash, hash_type),
        type: Types::Script.new(
          code_hash: api.dao_type_hash,
          args: "0x",
          hash_type: "type"
        )
      )
      output_data = "0x"
      tx_size += TransactionSize.every_output(output)
      tx_size += TransactionSize.every_outputs_data(output_data)

      change_output = Types::Output.new(
        capacity: 0,
        lock: lock
      )
      change_output_data = "0x"
      tx_size += TransactionSize.every_output(change_output)
      tx_size += TransactionSize.every_outputs_data(change_output_data)

      i = gather_inputs(
        capacity,
        output.calculate_min_capacity(output_data),
        change_output.calculate_min_capacity(change_output_data),
        fee_rate
      )
      input_capacities = i.capacities

      outputs = [output]
      outputs_data = [output_data]
      change_output.capacity = (input_capacities - (capacity + tx_size * fee_rate / BigDecimal(1000) + i.need_fee)).floor
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
      send_transaction(tx.sign(key, tx_hash))

      Types::OutPoint.new(tx_hash: tx_hash, index: 0)
    end

    # @param out_point [CKB::Type::OutPoint]
    # @param key [CKB::Key | String] Key or private key hex string
    #
    # @return [CKB::Type::Transaction]
    def generate_withdraw_from_dao_transaction(out_point, key: nil, fee_rate: 0)
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
      deposit_epoch = self.class.parse_epoch(deposit_block.epoch)
      deposit_block_number = deposit_block.number
      current_block = api.get_tip_header
      current_epoch = self.class.parse_epoch(current_block.epoch)
      current_block_number = current_block.number

      if deposit_block_number == current_block_number
        raise "You need to at least wait for 1 block before generating DAO withdraw transaction!"
      end

      withdraw_fraction = current_epoch.index * deposit_epoch.length
      deposit_fraction = deposit_epoch.index * current_epoch.length
      deposited_epoches = current_epoch.number - deposit_epoch.number
      deposited_epoches +=1 if withdraw_fraction > deposit_fraction
      lock_epochs = (deposited_epoches + (DAO_LOCK_PERIOD_EPOCHS - 1)) / DAO_LOCK_PERIOD_EPOCHS * DAO_LOCK_PERIOD_EPOCHS
      minimal_since_epoch_number = deposit_epoch.number + lock_epochs
      minimal_since_epoch_index = deposit_epoch.index
      minimal_since_epoch_length = deposit_epoch.length

      minimal_since = self.class.epoch_since(minimal_since_epoch_length, minimal_since_epoch_index, minimal_since_epoch_number)

      # a hex string
      output_capacity = api.calculate_dao_maximum_withdraw(out_point, current_block.hash)

      dup_out_point = out_point.dup
      new_out_point = Types::OutPoint.new(
        tx_hash: dup_out_point.tx_hash,
        index: dup_out_point.index
      )

      output = Types::Output.new(capacity: output_capacity, lock: lock)
      outputs = [output]
      outputs_data = ["0x"]
      witness = "0x0000000000000000"

      tx_size =
        TransactionSize.base_size +
        TransactionSize.every_cell_dep * 2 +
        TransactionSize.every_header_dep * 2 +
        TransactionSize.every_input +
        TransactionSize.every_output(output) +
        outputs_data.map { |data| TransactionSize.every_outputs_data(data) }.reduce(:+) +
        TransactionSize.every_secp_witness(witness)

      fee = Types::Transaction.fee(tx_size, fee_rate)
      output.capacity = output.capacity - fee

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
          Types::Input.new(previous_output: new_out_point, since: minimal_since)
        ],
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: [witness]
      )
      tx.sign(key, tx.compute_hash)
    end

    # @param epoch [Integer]
    def self.parse_epoch(epoch)
      OpenStruct.new(
        length: (epoch >> 40) & 0xFFFF,
        index: (epoch >> 24) & 0xFFFF,
        number: (epoch) & 0xFFFFFF
      )
    end

    def self.epoch_since(length, index, number)
      (0x20 << 56) + (length << 40) + (index << 24) + number
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
      @lock_hash ||= lock.compute_hash
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
    def gather_inputs(capacity, min_capacity, min_change_capacity, fee_rate)
      CellCollectorByFeeRate.new(
        @api,
        skip_data_and_type: @skip_data_and_type,
        hash_type: @hash_type
      ).gather_inputs(
        [lock_hash],
        capacity,
        min_capacity,
        min_change_capacity,
        fee_rate
      )
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
