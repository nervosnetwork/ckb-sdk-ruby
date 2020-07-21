# frozen_string_literal: true

module CKB
  module Types
    class TransactionPoint
      attr_accessor :block_number, :tx_hash, :index

      # @param block_number [String | Integer] integer or hex number
      # @param tx_hash [String]
      # @param index [String | Integer] integer or hex number
      def initialize(block_number:, tx_hash:, index:)
        @block_number = Utils.to_int(block_number)
        @tx_hash = tx_hash
        @index = Utils.to_int(index)
      end

      def to_h
        {
          block_number: Utils.to_hex(@block_number),
          tx_hash: @tx_hash,
          index: Utils.to_hex(@index)
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
