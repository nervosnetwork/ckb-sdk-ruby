# frozen_string_literal: true

module CKB
  module Types
    class Transaction
      attr_reader :version, :deps, :inputs, :outputs, :witnesses, :hash

      def initialize(hash: nil, version: 0, deps: [], inputs: [], outputs: [], witnesses: [])
        @hash = hash
        @version = version
        @deps = deps
        @inputs = inputs
        @outputs = outputs
        @witnesses = witnesses
      end

      def sign(key, tx_hash)
        signature_hex_var = signature_hex(key, tx_hash)
        signature_size = Utils.hex_to_bin(signature_hex_var).size

        witnesses = inputs.map do |_input|
          Types::Witness.from_h(
            data: [key.pubkey, signature_hex_var,
                   Utils.bin_to_hex([signature_size].pack("Q<"))]
          )
        end

        self.class.new(
          hash: hash,
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

      private

      def signature_hex(key, tx_hash)
        blake2b = CKB::Blake2b.new
        blake2b.update(Utils.hex_to_bin(tx_hash))
        privkey_bin = Utils.hex_to_bin(key.privkey)
        secp_key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
        signature_bin = secp_key.ecdsa_serialize(
          secp_key.ecdsa_sign(blake2b.digest, raw: true)
        )
        Utils.bin_to_hex(signature_bin)
      end
    end
  end
end
