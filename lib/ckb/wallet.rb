# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "secp256k1"

module CKB
  MIN_CELL_CAPACITY = 40 * (10 ** 8)

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
      get_unspent_cells.map { |cell| cell[:capacity].to_i }.reduce(0, &:+)
    end

    def generate_tx(target_address, capacity)
      i = gather_inputs(capacity, MIN_CELL_CAPACITY)
      input_capacities = i.capacities

      outputs = [
        {
          capacity: capacity.to_s,
          data: "0x",
          lock: CKB::Utils.generate_lock(
            key.address.parse(target_address),
            api.system_script_cell_hash
          )
        }
      ]
      if input_capacities > capacity
        outputs << {
          capacity: (input_capacities - capacity).to_s,
          data: "0x",
          lock: lock
        }
      end

      tx = Transaction.new(
        version: 0,
        deps: [api.system_script_out_point],
        inputs: i.inputs,
        outputs: outputs
      )

      tx.sign(key)
    end

    # @param target_address [String]
    # @param capacity [Integer]
    def send_capacity(target_address, capacity)
      tx = generate_tx(target_address, capacity)
      send_transaction(tx)
    end

    # @param hash_hex [String] "0x..."
    def get_transaction(hash)
      api.get_transaction(hash)
    end

    def block_assembler_config
      %(
[block_assembler]
code_hash = "#{lock[:code_hash]}"
args = #{lock[:args]}
     ).strip
    end

    def address
      @key.address.to_s
    end

    private

    # @param transaction [CKB::Transaction | Hash]
    def send_transaction(transaction)
      api.send_transaction(transaction.to_h)
    end

    def gather_inputs(capacity, min_capacity)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      input_capacities = 0
      inputs = []
      pubkeys = []
      get_unspent_cells.each do |cell|
        input = {
          previous_output: cell[:out_point],
          args: [],
          since: "0"
        }
        pubkeys << pubkey
        inputs << input
        input_capacities += cell[:capacity].to_i

        break if input_capacities >= capacity && (input_capacities - capacity) >= min_capacity
      end

      raise "Not enough capacity!" if input_capacities < capacity

      OpenStruct.new(inputs: inputs, capacities: input_capacities, pubkeys: pubkeys)
    end

    def pubkey
      @key.pubkey
    end

    def lock_hash
      @lock_hash ||= CKB::Utils.json_script_to_type_hash(lock)
    end

    def lock
      CKB::Utils.generate_lock(
        @key.address.blake160,
        api.system_script_cell_hash
      )
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
