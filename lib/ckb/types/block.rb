# frozen_string_literal: true

module CKB
  module Types
    class Block
      attr_accessor :uncles, :proposals, :transactions, :header

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

      # https://github.com/nervosnetwork/ckb/blob/develop/util/types/src/extension/serialized_size.rs#L22-L30
      def serialized_size_without_uncle_proposals
        block_size = CKB::Serializers::BlockSerializer.new(self).capacity
        uncles_proposals_size = self.uncles.map { |uncle| uncle.proposals.map { |proposal| CKB::Serializers::ProposalShortIdSerializer.new(proposal).capacity - CKB::Serializers::TableSerializer::UINT32_CAPACITY }.sum }.sum

        block_size - uncles_proposals_size
      end

      def to_h
        {
          uncles: @uncles.map(&:to_h),
          proposals: @proposals,
          transactions: @transactions.map(&:to_h),
          header: header.to_h
        }
      end

      def to_raw_block_h
        {
          uncles: uncles.map(&:to_h),
          proposals: proposals,
          transactions: transactions.map(&:to_raw_transaction_h),
          header: header.to_h.reject { |key| key == :hash }
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
