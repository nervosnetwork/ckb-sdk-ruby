# frozen_string_literal: true

module CKB
  module Types
    class IndexerTip
      attr_accessor :block_hash, :block_number

      # @param block_hash [String]
      # @param block_number [String]
      def initialize(block_hash:, block_number:)
        @block_hash = block_hash
        @block_number = block_number
      end

      def to_h
        {
          block_hash: block_hash,
          block_number: block_number
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          block_hash: hash[:block_hash],
          block_number: hash[:block_number]
        )
      end
    end
  end
end
