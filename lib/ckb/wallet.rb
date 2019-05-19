# frozen_string_literal: true

require "secp256k1"

module CKB
  MIN_CELL_CAPACITY = 40 * (10**8)

  DAO_CODE_HASH = "0x0000000000000000000000000000004e4552564f5344414f434f444530303031"

  DAO_ISSUING_OUT_POINT = Types::OutPoint.new(
    cell: Types::CellOutPoint.new(
      tx_hash: "0x00000000000000000000000000004e4552564f5344414f494e50555430303031",
      index: 0))

  DAO_LOCK_PERIOD_BLOCKS = 10
  DAO_MATURITY_BLOCKS = 5

  class Wallet
    attr_reader :api
    # privkey is a bin string
    attr_reader :key

    # @param api [CKB::API]
    # @param key [CKB::Key]
    def initialize(api, key)
      @api = api
      @key = key
    end

    def self.from_hex(api, privkey)
      new(api, Key.new(privkey))
    end

    # @return [CKB::Types::Output[]]
    def get_unspent_cells
      to = api.get_tip_block_number.to_i
      results = []
      current_from = 1
      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = api.get_cells_by_lock_hash(lock_hash, current_from.to_s, current_to.to_s)
        results.concat(cells)
        current_from = current_to + 1
      end
      results
    end

    def get_balance
      get_unspent_cells.map { |cell| cell.capacity.to_i }.reduce(0, &:+)
    end

    def generate_tx(target_address, capacity, data = "0x")
      i = gather_inputs(capacity, MIN_CELL_CAPACITY)
      input_capacities = i.capacities

      outputs = [
        Types::Output.new(
          capacity: capacity,
          data: data,
          lock: Types::Script.generate_lock(
            key.address.parse(target_address),
            api.system_script_code_hash
          )
        )
      ]
      if input_capacities > capacity
        outputs << Types::Output.new(
          capacity: input_capacities - capacity,
          lock: lock
        )
      end

      tx = Types::Transaction.new(
        version: 0,
        deps: [api.system_script_out_point],
        inputs: i.inputs,
        outputs: outputs
      )
      tx_hash = api.compute_transaction_hash(tx)

      tx.sign(key, tx_hash)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    # @param data [String] "0x..."
    def send_capacity(target_address, capacity, data = "0x")
      tx = generate_tx(target_address, capacity, data)
      send_transaction(tx)
    end

    def deposit_to_dao(capacity)
      i = gather_inputs(capacity, MIN_CELL_CAPACITY)
      input_capacities = i.capacities

      outputs = [
        Types::Output.new(
          capacity: capacity,
          lock: Types::Script.generate_lock(@key.address.blake160, DAO_CODE_HASH)
        )
      ]
      if input_capacities > capacity
        outputs << Types::Output.new(
          capacity: input_capacities - capacity,
          lock: lock
        )
      end

      tx = Types::Transaction.new(
        version: 0,
        deps: [api.system_script_out_point],
        inputs: i.inputs,
        outputs: outputs
      )
      tx_hash = api.compute_transaction_hash(tx)
      send_transaction(tx.sign(key, tx_hash))

      Types::OutPoint.new(cell: Types::CellOutPoint.new(tx_hash: tx_hash, index: 0))
    end

    def generate_withdraw_from_dao_transaction(cell_out_point)
      cell_status = api.get_live_cell(cell_out_point)
      unless cell_status.status == "live"
        raise "Cell is not yet live!"
      end
      tx = api.get_transaction(cell_out_point.cell.tx_hash)
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

      output_capacity = api.calculate_dao_maximum_withdraw(cell_out_point, current_block.hash).to_i

      new_cell_out_point = Types::OutPoint.new(
        block_hash: deposit_block.hash,
        cell: cell_out_point.cell.dup
      )
      tx = Types::Transaction.new(
        version: 0,
        deps: [{block_hash: current_block.hash}],
        inputs: [
          Types::Input.new(args: [current_block.hash], previous_output: new_cell_out_point, since: since),
          Types::Input.new(args: [], previous_output: DAO_ISSUING_OUT_POINT)
        ],
        outputs: [
          Types::Output.new(capacity: output_capacity, lock: lock)
        ]
      )
      tx_hash = api.compute_transaction_hash(tx)
      tx = tx.sign(key, tx_hash)
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

    def address
      @key.address.to_s
    end

    private

    # @param transaction [CKB::Transaction]
    def send_transaction(transaction)
      api.send_transaction(transaction)
    end

    # @param capacity [Integer]
    # @param min_capacity [Integer]
    def gather_inputs(capacity, min_capacity)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      input_capacities = 0
      inputs = []
      pubkeys = []
      get_unspent_cells.each do |cell|
        input = Types::Input.new(
          previous_output: cell.out_point,
          args: [],
          since: "0"
        )
        pubkeys << pubkey
        inputs << input
        input_capacities += cell.capacity.to_i

        diff = input_capacities - capacity
        break if input_capacities >= capacity && (diff >= min_capacity || diff.zero?)
      end

      raise "Not enough capacity!" if input_capacities < capacity

      OpenStruct.new(inputs: inputs, capacities: input_capacities, pubkeys: pubkeys)
    end

    def pubkey
      @key.pubkey
    end

    def lock_hash
      @lock_hash ||= lock.to_hash
    end

    # @return [CKB::Types::Script]
    def lock
      Types::Script.generate_lock(
        @key.address.blake160,
        api.system_script_code_hash
      )
    end
  end
end
