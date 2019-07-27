# frozen_string_literal: true

module CKB
  module Types
    class TxPoolInfo
      attr_accessor :pending, :proposed, :orphan, :total_tx_cycles, :total_tx_size, :last_txs_updated_at

      # @param pending [String] number
      # @param proposed [String] number
      # @param orphan [String] number
      # @param total_tx_cycles [String] number
      # @param total_tx_size [String] number
      # @param last_txs_updated_at [String] timestamp
      def initialize(
        pending:,
        proposed:,
        orphan:,
        last_txs_updated_at:,
        total_tx_cycles:,
        total_tx_size:
      )
        @pending = pending.to_s
        @proposed = proposed.to_s
        @orphan = orphan.to_s
        @total_tx_cycles = total_tx_cycles.to_s
        @total_tx_size = total_tx_size.to_s
        @last_txs_updated_at = last_txs_updated_at
      end

      def to_h
        {
          pending: @pending,
          proposed: @proposed,
          orphan: @orphan,
          total_tx_cycles: @total_tx_cycles,
          total_tx_size: @total_tx_size,
          last_txs_updated_at: @last_txs_updated_at
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          pending: hash[:pending],
          proposed: hash[:proposed],
          orphan: hash[:orphan],
          total_tx_cycles: hash[:total_tx_cycles],
          total_tx_size: hash[:total_tx_size],
          last_txs_updated_at: hash[:last_txs_updated_at]
        )
      end
    end
  end
end
