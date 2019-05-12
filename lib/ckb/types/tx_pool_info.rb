# frozen_string_literal: true

module CKB
  module Types
    class TxPoolInfo
      attr_reader :pending, :proposed, :orphan, :last_txs_updated_at

      # @param pending [Integer]
      # @param proposed [Integer]
      # @param orphan [Integer]
      # @param last_txs_updated_at [String] timestamp
      def initialize(pending:, proposed:, orphan:, last_txs_updated_at:)
        @pending = pending
        @proposed = proposed
        @orphan = orphan
        @last_txs_updated_at = last_txs_updated_at
      end

      def to_h
        {
          pending: @pending,
          proposed: @proposed,
          orphan: @orphan,
          last_txs_updated_at: @last_txs_updated_at
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          pending: hash[:pending].to_i,
          proposed: hash[:proposed].to_i,
          orphan: hash[:orphan].to_i,
          last_txs_updated_at: hash[:last_txs_updated_at]
        )
      end
    end
  end
end
