# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "secp256k1"

module CKB
  MIN_CELL_CAPACITY = 40

  class Wallet
    attr_reader :rpc
    # privkey is a bin string
    attr_reader :privkey

    # @param rpc [CKB::RPC]
    # @param privkey [String] bin string
    def initialize(rpc, privkey)
      raise ArgumentError, "invalid privkey!" unless privkey.instance_of?(String) && privkey.size == 32

      @rpc = rpc
      @privkey = privkey
    end

    # @param rpc [CKB::RPC]
    # @param privkey_hex [String] hex string
    #
    # @return [CKB::Wallet]
    def self.from_hex(rpc, privkey_hex)
      new(rpc, CKB::Utils.hex_to_bin(privkey_hex))
    end

    def address
      verify_type_hash
    end

    def get_unspent_cells
      to = rpc.get_tip_block_number
      results = []
      current_from = 1
      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = rpc.get_cells_by_type_hash(address, current_from, current_to)
        results.concat(cells)
        current_from = current_to + 1
      end
      results
    end

    def get_balance
      get_unspent_cells.map { |cell| cell[:capacity] }.reduce(0, &:+)
    end

    def generate_tx(target_address, capacity)
      i = gather_inputs(capacity, MIN_CELL_CAPACITY)
      input_capacities = i.capacities

      outputs = [
        {
          capacity: capacity,
          data: "",
          lock: target_address
        }
      ]
      if input_capacities > capacity
        outputs << {
          capacity: input_capacities - capacity,
          data: "",
          lock: address
        }
      end
      {
        version: 0,
        deps: [rpc.system_script_out_point],
        inputs: CKB::Utils.sign_sighash_all_inputs(i.inputs, outputs, privkey),
        outputs: outputs
      }
    end

    # @param target_address [String] "0x..."
    # @param capacity [Integer]
    def send_capacity(target_address, capacity)
      tx = generate_tx(target_address, capacity)
      send_transaction_bin(tx)
    end

    # @param hash_hex [String] "0x..."
    def get_transaction(hash_hex)
      rpc.get_transaction(hash_hex)
    end

    private

    def send_transaction_bin(transaction)
      transaction = CKB::Utils.normalize_tx_for_json!(transaction)
      rpc.send_transaction(transaction)
    end

    def gather_inputs(capacity, min_capacity)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      input_capacities = 0
      inputs = []
      get_unspent_cells.each do |cell|
        input = {
          previous_output: cell[:out_point],
          unlock: verify_script_json_object
        }
        inputs << input
        input_capacities += cell[:capacity]

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

    def verify_script_json_object
      {
        version: 0,
        reference: rpc.system_script_cell_hash,
        signed_args: [
          # We could of course just hash raw bytes, but since right now CKB
          # CLI already uses this scheme, we stick to the same way for compatibility
          pubkey
        ]
      }
    end

    def verify_type_hash
      @verify_type_hash ||= CKB::Utils.json_script_to_type_hash(verify_script_json_object)
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
