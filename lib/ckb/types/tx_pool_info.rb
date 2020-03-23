# frozen_string_literal: true

module CKB
  module Types
    class TxPoolInfo
      attr_accessor :pending, :proposed, :orphan, :total_tx_cycles, :total_tx_size, :last_txs_updated_at, :min_fee_rate

      # @param pending [String | Integer] integer or hex number
      # @param proposed [String | Integer] integer or hex number
      # @param orphan [String | Integer] integer or hex number
      # @param total_tx_cycles [String | Integer] integer or hex number
      # @param total_tx_size [String | Integer] integer or hex number
      # @param last_txs_updated_at [String | Integer] timestamp
      def initialize(
        pending:,
        proposed:,
        orphan:,
        last_txs_updated_at:,
        min_fee_rate:,
        total_tx_cycles:,
        total_tx_size:
      )
        @pending = Utils.to_int(pending)
        @proposed = Utils.to_int(proposed)
        @orphan = Utils.to_int(orphan)
        @total_tx_cycles = Utils.to_int(total_tx_cycles)
        @total_tx_size = Utils.to_int(total_tx_size)
        @last_txs_updated_at = Utils.to_int(last_txs_updated_at)
        @min_fee_rate = Utils.to_int(min_fee_rate)
      end

      def to_h
        {
          pending: Utils.to_hex(@pending),
          proposed: Utils.to_hex(@proposed),
          orphan: Utils.to_hex(@orphan),
          total_tx_cycles: Utils.to_hex(@total_tx_cycles),
          total_tx_size: Utils.to_hex(@total_tx_size),
          last_txs_updated_at: Utils.to_hex(@last_txs_updated_at),
          min_fee_rate: Utils.to_hex(@min_fee_rate)
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
          last_txs_updated_at: hash[:last_txs_updated_at],
          min_fee_rate: hash[:min_fee_rate]
        )
      end
    end
  end
end
