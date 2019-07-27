# frozen_string_literal: true

module CKB
  module Types
    class Seal
      attr_accessor :nonce, :proof

      # @param nonce [String] decimal number
      # @param proof [String] 0x...
      def initialize(nonce:, proof:)
        @nonce = nonce
        @proof = proof
      end

      def to_h
        {
          nonce: @nonce,
          proof: @proof
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          nonce: hash[:nonce],
          proof: hash[:proof]
        )
      end
    end
  end
end
