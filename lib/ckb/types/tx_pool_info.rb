# frozen_string_literal: true

module CKB
  module Types
    class TxPoolInfo
      attr_reader :pending, :staging, :orphan, :last_txs_updated_at

      # @param pending [Integer]
      # @param staging [Integer]
      # @param orphan [Integer]
      # @param last_txs_updated_at [String] timestamp
      def initialize(pending:, staging:, orphan:, last_txs_updated_at:)
        @pending = pending
        @staging = staging
        @orphan = orphan
        @last_txs_updated_at = last_txs_updated_at
      end

      def to_h
        {
          pending: @pending,
          staging: @staging,
          orphan: @orphan,
          last_txs_updated_at: @last_txs_updated_at
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        return hash if hash.is_a?(self.class)

        new(
          pending: hash[:pending],
          staging: hash[:staging],
          orphan: hash[:orphan],
          last_txs_updated_at: hash[:last_txs_updated_at]
        )
      end
    end
  end
end
