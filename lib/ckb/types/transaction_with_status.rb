# frozen_string_literal: true

module CKB
  module Types
    class TransactionWithStatus
      attr_accessor :transaction, :tx_status

      # @param transaction [CKB::Types::Transaction]
      # @param time_added_to_pool [String | nil]
      # @param tx_status [CKB::Types::TxStatus]
      # @param cycles [String[]]
      def initialize(transaction:, tx_status:, cycles:, time_added_to_pool:)
        @transaction = transaction
        @cycles = cycles
        @time_added_to_pool = time_added_to_pool
        @tx_status = tx_status
      end

      def to_h
        {
          transaction: @transaction.to_h,
          cycles: @cycles,
          time_added_to_pool: @time_added_to_pool,
          tx_status: @tx_status.to_h
        }
      end

      def self.from_h(hash, verbosity)
        return if hash.nil?

        new(
          transaction: verbosity == 2 ? Transaction.from_h(hash[:transaction]) : hash[:transaction],
          cycles: hash[:cycles],
          time_added_to_pool: hash[:time_added_to_pool],
          tx_status: TxStatus.from_h(hash[:tx_status])
        )
      end
    end
  end
end
