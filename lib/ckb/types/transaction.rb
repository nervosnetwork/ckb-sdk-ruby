# frozen_string_literal: true

module CKB
  module Types
    class Transaction
      attr_reader :version, :deps, :inputs, :outputs, :witnesses, :hash

      # @param hash [String | nil] 0x...
      # @param version [String]
      # @param deps [CKB::Types::OutPoint[]]
      # @param inputs [CKB::Types::Input[]]
      # @param outputs [CKB::Types::Output[]]
      # @param witnesses [CKB::Types::Witness[]]
      def initialize(
        hash: nil,
        version: 0,
        deps: [],
        inputs: [],
        outputs: [],
        witnesses: []
      )
        @hash = hash
        @version = version.to_s
        @deps = deps
        @inputs = inputs
        @outputs = outputs
        @witnesses = witnesses
      end

      # @param key [CKB::Key]
      # @param tx_hash [String] 0x...
      def sign(key, tx_hash)
        signature_hex_var = key.sign(tx_hash)
        signature_size = Utils.hex_to_bin(signature_hex_var).size
        data = [key.pubkey, signature_hex_var, Utils.bin_to_hex([signature_size].pack("Q<"))]
        witnesses = inputs.size.times.map do
          Types::Witness.from_h(data: data)
        end

        self.class.new(
          hash: tx_hash, # using real tx_hash instead
          version: version,
          deps: deps,
          inputs: inputs,
          outputs: outputs,
          witnesses: witnesses
        )
      end

      def to_h
        hash = {
          version: @version,
          deps: @deps.map(&:to_h),
          inputs: @inputs.map(&:to_h),
          outputs: @outputs.map(&:to_h),
          witnesses: @witnesses.map(&:to_h)
        }
        hash[:hash] = @hash if @hash
        hash
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          version: hash[:version],
          deps: hash[:deps]&.map { |dep| OutPoint.from_h(dep) },
          inputs: hash[:inputs].map { |input| Input.from_h(input) },
          outputs: hash[:outputs].map { |output| Output.from_h(output) },
          witnesses: hash[:witnesses].map { |witness| Witness.from_h(witness) }
        )
      end
    end
  end
end
