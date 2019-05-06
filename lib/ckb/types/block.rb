# frozen_string_literal: true

module CKB
  module Types
    class Block
      attr_reader :transactions, :header

      # @param transactions [CKB::Type::Transaction[]]
      # @param header [CKB::Type::BlockHeader]
      def initialize(transactions:, header:)
        @transactions = transactions
        @header = header
      end

      def to_h
        {
          transactions: @transaction.map(&:to_h),
          header: header
        }
      end

      def self.from_h(hash)
        new(
          transactions: hash[:transactions].map { |tx| Transaction.from_h(tx) },
          header: BlockHeader.from_h(hash[:header])
        )
      end
    end
  end
end
