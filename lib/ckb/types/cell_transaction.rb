# frozen_string_literal: true

module CKB
  module Types
    class CellTransaction
      attr_reader :created_by, :consumed_by

      # @param created_by [Types::TransactionPoint]
      # @param consumed_by [Types::TransactionPoint | nil]
      def initialize(created_by:, consumed_by: nil)
        @created_by = created_by
        @consumed_by = consumed_by
      end

      def to_h
        {
          created_by: @created_by,
          consumed_by: @consumed_by
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        consumed_by = hash[:consumed_by]

        new(
          created_by: TransactionPoint.from_h(hash[:created_by]),
          consumed_by: consumed_by ? TransactionPoint.from_h(consumed_by) : nil
        )
      end
    end
  end
end