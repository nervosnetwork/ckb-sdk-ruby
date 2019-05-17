# frozen_string_literal: true

module CKB
  module Types
    class Block
      attr_reader :uncles, :proposals, :transactions, :header

      # @param uncles [CKB::Types::Uncle[]]
      # @param proposals [String[]] 0x...
      # @param transactions [CKB::Type::Transaction[]]
      # @param header [CKB::Type::BlockHeader]
      def initialize(uncles:, proposals:, transactions:, header:)
        @uncles = uncles
        @proposals = proposals
        @transactions = transactions
        @header = header
      end

      def to_h
        {
          uncles: @uncles.map(&:to_h),
          proposals: @proposals,
          transactions: @transactions.map(&:to_h),
          header: header.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          uncles: hash[:uncles].map { |uncle| Uncle.from_h(uncle) },
          proposals: hash[:proposals],
          transactions: hash[:transactions].map { |tx| Transaction.from_h(tx) },
          header: BlockHeader.from_h(hash[:header])
        )
      end
    end
  end
end
