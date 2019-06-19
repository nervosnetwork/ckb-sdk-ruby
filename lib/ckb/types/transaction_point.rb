# frozen_string_literal: true

module CKB
  module Types
    class TransactionPoint
      attr_reader :block_number, :tx_hash, :index

      # @param block_number [String]
      # @param tx_hash [String]
      # @param index [String]
      def initialize(block_number:, tx_hash:, index:)
        @block_number = block_number.to_s
        @tx_hash = tx_hash
        @index = index.to_s
      end

      def to_h
        {
          block_number: @block_number,
          tx_hash: @tx_hash,
          index: @index
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          block_number: hash[:block_number],
          tx_hash: hash[:tx_hash],
          index: hash[:index]
        )
      end
    end
  end
end