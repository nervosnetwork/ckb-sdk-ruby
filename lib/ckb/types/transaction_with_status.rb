# frozen_string_literal: true

module CKB
  module Types
    class TransactionWithStatus
      attr_reader :transaction, :tx_status
      # @param transaction [CKB::Types::Transaction]
      # @param tx_status [CKB::Types::TxStatus]
      def initialize(transaction:, tx_status:)
        @transaction = transaction
        @tx_status = tx_status
      end

      def to_h
        {
          transaction: @transaction.to_h,
          tx_status: @tx_status.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          transaction: Transaction.from_h(hash[:transaction]),
          tx_status: TxStatus.from_h(hash[:tx_status])
        )
      end
    end
  end
end
