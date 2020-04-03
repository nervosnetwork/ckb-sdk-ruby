# frozen_string_literal: true

module CKB
  class NewWallet
    attr_accessor :from_block_number
    attr_reader :api, :collector_type, :mode, :input_scripts

    def initialize(api:, from_addresses:, collector_type: :default_scanner, mode: MODE::TESTNET, from_block_number: 0)
      @api = api
      @collector_type = collector_type
      @mode = mode
      @from_block_number = from_block_number
      @input_scripts = (from_addresses.is_a?(Array) ? from_addresses : [from_addresses]).map do |address|
        CKB::AddressParser.new(address).parse.script
      end
    end

    def generate(to_address, capacity, output_info = {}, fee_rate = 1)
      advance_generate(
        to_infos: { to_address => { capacity: capacity, type: output_info[:type], data: output_info[:data] } },
        contexts: [output_info[:context]],
        fee_rate: fee_rate
      )
    end

    def sign(tx_generator, context)
      advance_sign(tx_generator: tx_generator, contexts: [context])
    end

    # Build unsigned transaction
    # @param to_infos [Hash<String, Hash>], key: address, value: output infos. eg: { capacity: 1000, type: CKB::Types::Script.new(code_hash: "", args: "", hash_type: ""), data: "0x" }
    # @params contexts [hash], key: input lock script hash, value: tx generating context
    # @param fee_rate [Integer] Default 1 shannon / transaction byte
    def advance_generate(to_infos:, contexts: [], fee_rate: 1)
      outputs = []
      outputs_data = []
      to_infos.each do |to_address, output_info|
        script = CKB::AddressParser.new(to_address).parse.script
        outputs << CKB::Types::Output.new(capacity: output_info[:capacity], lock: script, type: output_info[:type])
        outputs_data << (output_info[:data] || "0x")
      end

      if outputs.all? { |output| output.capacity > 0 }
        outputs << CKB::Types::Output.new(capacity: 0, lock: input_scripts.first, type: nil)
        outputs_data << "0x"
      end
      transaction = CKB::Types::Transaction.new(
        version: 0, cell_deps: [], header_deps: [], inputs: [],
        outputs: outputs, outputs_data: outputs_data, witnesses: []
      )
      tx_generator = CKB::TransactionGenerator.new(api, transaction)

      tx_generator.generate(collector: collector, contexts: input_scripts.map(&:compute_hash).zip(contexts).to_h, fee_rate: fee_rate)
      tx_generator
    end

    def advance_sign(tx_generator:, contexts:)
      contexts = (contexts.is_a?(Array) ? contexts : [contexts])
      tx_generator.sign(input_scripts.map(&:compute_hash).zip(contexts).to_h)
      tx_generator.transaction
    end

    private

    def collector
      collector = if collector_type == :default_scanner
        CKB::Collector.new(api).default_scanner(lock_hashes: input_scripts.map(&:compute_hash), from_block_number: from_block_number)
      else
        CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))
      end

      Enumerator.new do |result|
        loop do
          begin
            cell_meta = collector.next
            if cell_meta.output_data_len == 0 && cell_meta.output.type.nil?
              result << cell_meta
            end
          rescue StopIteration
            break
          end
        end
      end
    end
  end
end
