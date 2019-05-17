# frozen_string_literal: true

module CKB
  module Types
    class TxPoolInfo
      attr_reader :pending, :proposed, :orphan, :last_txs_updated_at

      # @param pending [String] number
      # @param proposed [String] number
      # @param orphan [String] number
      # @param last_txs_updated_at [String] timestamp
      def initialize(pending:, proposed:, orphan:, last_txs_updated_at:)
        @pending = pending.to_s
        @proposed = proposed.to_s
        @orphan = orphan.to_s
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
          pending: hash[:pending],
          proposed: hash[:proposed],
          orphan: hash[:orphan],
          last_txs_updated_at: hash[:last_txs_updated_at]
        )
      end
    end
  end
end
