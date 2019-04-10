# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "secp256k1"

module CKB
  MIN_CELL_CAPACITY = 40

  class Wallet
    attr_reader :api
    # privkey is a bin string
    attr_reader :privkey

    # @param api [CKB::API]
    # @param privkey [String] bin string
    def initialize(api, privkey)
      raise ArgumentError, "invalid privkey!" unless privkey.instance_of?(String) && privkey.size == 32

      @api = api
      @privkey = privkey
    end

    # @param api [CKB::API]
    # @param privkey_hex [String] hex string
    #
    # @return [CKB::Wallet]
    def self.from_hex(api, privkey_hex)
      new(api, CKB::Utils.hex_to_bin(privkey_hex))
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
          data: "",
          lock: generate_lock(api.parse_address(target_address))
        }
      ]
      if input_capacities > capacity
        outputs << {
          capacity: (input_capacities - capacity).to_s,
          data: "",
          lock: lock
        }
      end
      {
        version: 0,
        deps: [api.system_script_out_point],
        inputs: CKB::Utils.sign_sighash_all_inputs(i.inputs, outputs, privkey),
        outputs: outputs,
        witnesses: []
      }
    end

    # @param target_address [String]
    # @param capacity [Integer]
    def send_capacity(target_address, capacity)
      tx = generate_tx(target_address, capacity)
      send_transaction_bin(tx)
    end

    # @param hash_hex [String] "0x..."
    def get_transaction(hash_hex)
      api.get_transaction(hash_hex)
    end

    def block_assembler_config
      args = lock[:args].map do |arg|
        "[#{arg.bytes.map(&:to_s).join(", ")}]"
      end.join(", ")
      %Q(
[block_assembler]
binary_hash = "#{lock[:binary_hash]}"
args = [#{args}]
     ).strip
    end

    def address
      api.generate_address(pubkey_hash_bin)
    end

    private

    def send_transaction_bin(transaction)
      transaction = CKB::Utils.normalize_tx_for_json!(transaction)
      api.send_transaction(transaction)
    end

    def gather_inputs(capacity, min_capacity)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      input_capacities = 0
      inputs = []
      get_unspent_cells.each do |cell|
        input = {
          previous_output: cell[:out_point],
          args: [pubkey]
        }
        inputs << input
        input_capacities += cell[:capacity].to_i

        break if input_capacities >= capacity && (input_capacities - capacity) >= min_capacity
      end

      raise "Not enough capacity!" if input_capacities < capacity

      OpenStruct.new(inputs: inputs, capacities: input_capacities)
    end

    def pubkey
      CKB::Utils.bin_to_hex(pubkey_bin)
    end

    def pubkey_bin
      CKB::Utils.extract_pubkey_bin(privkey)
    end

    def pubkey_hash_bin
      CKB::Utils.pubkey_hash_bin(pubkey_bin)
    end

    def lock_hash
      @lock_hash ||= CKB::Utils.json_script_to_type_hash(lock)
    end

    def lock
      generate_lock(pubkey_hash_bin)
    end

    def generate_lock(target_pubkey_hash_bin)
      {
        binary_hash: api.system_script_cell_hash,
        args: [
          CKB::Utils.bin_to_hex(target_pubkey_hash_bin)
        ]
      }
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
