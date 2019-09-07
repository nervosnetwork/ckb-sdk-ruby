# frozen_string_literal: true

module CKB
  module Types
    class Transaction
      attr_accessor :version, :cell_deps, :header_deps, :inputs, :outputs, :outputs_data, :witnesses, :hash

      # @param hash [String | nil] 0x...
      # @param version [String]
      # @param cell_deps [CKB::Types::CellDep[]]
      # @param header_deps [String[]]
      # @param inputs [CKB::Types::Input[]]
      # @param outputs [CKB::Types::Output[]]
      # @param outputs_data [String[]]
      # @param witnesses [CKB::Types::Witness[]]
      def initialize(
        hash: nil,
        version: 0,
        cell_deps: [],
        header_deps: [],
        inputs: [],
        outputs: [],
        outputs_data: [],
        witnesses: []
      )
        @hash = hash
        @version = version.to_s
        @cell_deps = cell_deps
        @header_deps = header_deps
        @inputs = inputs
        @outputs = outputs
        @outputs_data = outputs_data
        @witnesses = witnesses
      end

      # @param key [CKB::Key]
      # @param tx_hash [String] 0x...
      def sign(key, tx_hash)
        raise "Invalid number of witnesses!" if witnesses.length < inputs.length

        signed_witnesses = witnesses.map do |witness|
          old_data = witness.data || []
          blake2b = CKB::Blake2b.new
          blake2b.update(Utils.hex_to_bin(tx_hash))
          old_data.each do |datum|
            blake2b.update(Utils.hex_to_bin(datum))
          end
          message = blake2b.hexdigest
          data = [key.sign_recoverable(message)] + old_data
          Types::Witness.from_h(data: data)
        end

        self.class.new(
          hash: tx_hash, # using real tx_hash instead
          version: version,
          cell_deps: cell_deps,
          header_deps: header_deps,
          inputs: inputs,
          outputs: outputs,
          outputs_data: outputs_data,
          witnesses: signed_witnesses
        )
      end

      def to_h
        hash = {
          version: @version,
          cell_deps: @cell_deps.map(&:to_h),
          header_deps: @header_deps,
          inputs: @inputs.map(&:to_h),
          outputs: @outputs.map(&:to_h),
          outputs_data: @outputs_data,
          witnesses: @witnesses.map(&:to_h)
        }
        hash[:hash] = @hash if @hash
        hash
      end

      def compute_hash
        raw_transaction_serializer = CKB::Serializers::RawTransactionSerializer.new(self)
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin(raw_transaction_serializer.serialize)
        blake2b.hexdigest
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          version: hash[:version],
          header_deps: hash[:header_deps],
          cell_deps: hash[:cell_deps].map { |dep| CellDep.from_h(dep) },
          inputs: hash[:inputs].map { |input| Input.from_h(input) },
          outputs: hash[:outputs].map { |output| Output.from_h(output) },
          outputs_data: hash[:outputs_data],
          witnesses: hash[:witnesses].map { |witness| Witness.from_h(witness) }
        )
      end
    end
  end
end
