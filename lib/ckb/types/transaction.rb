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
          deps: deps,
          inputs: inputs,
          outputs: outputs,
          witnesses: signed_witnesses
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
