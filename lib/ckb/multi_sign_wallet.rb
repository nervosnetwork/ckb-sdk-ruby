# frozen_string_literal: true

module CKB
  class MultiSignConfiguration
    attr_reader :require_n
    attr_reader :threshold
    attr_reader :pubkeys
    attr_reader :since

    def initialize(require_n:, threshold:, pubkeys:, since:)
      raise "require_n should be less than 256" if require_n > 255 || require_n < 0
      raise "threshold should be less than 256" if threshold > 255 || threshold < 0
      raise "Pubkey number must be less than 256" if pubkeys.length > 255

      @require_n = require_n
      @threshold = threshold
      @pubkeys = pubkeys
      @since = since
    end

    def self.from_private_keys(require_n:, threshold:, private_keys:, since:)
      pubkeys = private_keys.map do |privkey|
        CKB::Key.new(privkey).pubkey
      end
      new(require_n: require_n,
          threshold: threshold,
          pubkeys: pubkeys,
          since: since)
    end

    def serialize
      CKB::Utils.bin_to_hex(
        [0, require_n, threshold, pubkeys.length].pack("CCCC") +
        pubkeys.map do |pubkey|
          CKB::Blake2b.digest(CKB::Utils.hex_to_bin(pubkey))[0..19]
        end.reduce(&:+)
      )
    end

    def blake160
      hash_bin = CKB::Blake2b.digest(CKB::Utils.hex_to_bin(serialize))
      Utils.bin_to_hex(hash_bin[0...20])
    end

    def lock_args
      Utils.hex_concat(blake160, Utils.bin_to_hex([since].pack("Q<")))
    end
  end

  class MultiSignWallet
    attr_reader :api
    attr_reader :configuration
    attr_reader :skip_data_and_type
    attr_reader :prefix
    attr_reader :indexer_api

    def initialize(api, configuration, skip_data_and_type: true, prefix: CKB::Address::PREFIX_TESTNET, indexer_api: nil)
      @api = api
      @indexer_api = indexer_api
      @configuration = configuration
      @skip_data_and_type = skip_data_and_type
      @prefix = prefix
    end

    def address
      payload = [CKB::Address::FULL_TYPE_FORMAT].pack("H*") + CKB::Utils.hex_to_bin(api.multi_sign_secp_cell_type_hash) + CKB::Utils.hex_to_bin(configuration.lock_args)
      ConvertAddress.encode(prefix, payload)
    end

    def lock
      Types::Script.new(
        code_hash: api.multi_sign_secp_cell_type_hash,
        hash_type: "type",
        args: configuration.lock_args
      )
    end

    def search_key
      @search_key ||= CKB::Indexer::Types::SearchKey.new(lock, "lock")
    end

    def get_balance
      CellCollector.new(
        indexer_api,
        skip_data_and_type: skip_data_and_type
      ).get_unspent_cells(
        search_key: search_key
      )[:total_capacities]
    end

    def generate_tx(target_address, capacity, private_keys, data: "0x", fee: 0)
      raise "Invalid number of keys" if private_keys.length != configuration.threshold

      parsed_address = AddressParser.new(target_address).parse
      if parsed_address.address_type != "SHORTSINGLESIG"
        raise "Right now only supports sending to default single signed lock!"
      end

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

      min_capacity = output.calculate_min_capacity(output_data)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      i = CellCollector.new(
        indexer_api,
        skip_data_and_type: skip_data_and_type
      ).gather_inputs(
        [search_key],
        capacity,
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
        cell_deps: [Types::CellDep.new(out_point: api.multi_sign_secp_group_out_point, dep_type: "dep_group")],
        inputs: i.inputs.map do |input|
          dupped_input = input.dup
          # TODO: auto-detect if since value has passed
          dupped_input.since = configuration.since
          dupped_input
        end,
        outputs: outputs,
        outputs_data: outputs_data,
        witnesses: i.witnesses
      )

      # Multi sign
      tx_hash = tx.compute_hash
      blake2b = CKB::Blake2b.new
      blake2b.update(Utils.hex_to_bin(tx_hash))

      empty_signature = Utils.bin_to_hex(("\x00" * 65) * private_keys.length)
      emptied_witness = tx.witnesses[0].dup
      emptied_witness.lock = Utils.hex_concat(configuration.serialize, empty_signature)
      emptied_witness_data_binary = Utils.hex_to_bin(
          Serializers::WitnessArgsSerializer.new(emptied_witness).serialize
      )
      emptied_witness_data_size = emptied_witness_data_binary.bytesize

      blake2b.update([emptied_witness_data_size].pack("Q<"))
      blake2b.update(emptied_witness_data_binary)

      tx.witnesses[1..-1].each do |witness|
        data_binary =
          case witness
          when CKB::Types::Witness
            Utils.hex_to_bin(CKB::Serializers::WitnessArgsSerializer.new(witness).serialize)
          else
            Utils.hex_to_bin(witness)
          end
        data_size = data_binary.bytesize

        blake2b.update([data_size].pack("Q<"))
        blake2b.update(data_binary)
      end
      message = blake2b.hexdigest

      signatures = private_keys.map do |private_key|
        private_key = CKB::Key.new(private_key) unless private_key.instance_of?(CKB::Key)
        private_key.sign_recoverable(message)
      end
      concatenated_signatures = signatures.reduce do |acc, signature|
        Utils.hex_concat(acc, signature)
      end

      tx.witnesses[0].lock = Utils.hex_concat(
        configuration.serialize, concatenated_signatures
      )

      tx
    end

    def send_capacity(target_address, capacity, private_keys, data: "0x", fee: 0)
      tx = generate_tx(target_address, capacity, private_keys, data: data, fee: fee)
      api.send_transaction(tx)
    end
  end
end
