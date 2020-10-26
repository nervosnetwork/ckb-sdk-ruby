# frozen_string_literal: true

module CKB
  module Types
    class MerkleProof
      attr_accessor :indices, :lemmas

      # @param indices [String[]]
      # @param lemmas [String[]]
      def initialize(indices:, lemmas:)
        @indices = indices.map { |index| Utils.to_int(index) }
        @lemmas = lemmas
      end

      def to_h
        {
          indices: indices.map { |index| Utils.to_hex(index) },
          lemmas: lemmas
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          indices: hash[:indices],
          lemmas: hash[:lemmas]
        )
      end
    end
  end
end
