# frozen_string_literal: true

module CKB
  module Types
    class SyncState
      attr_accessor :best_known_block_number, :best_known_block_timestamp, :fast_time, :ibd, :inflight_blocks_count,
                    :low_time, :normal_time, :orphan_blocks_count

      # @param best_known_block_number [String | Integer] integer or hex number
      # @param best_known_block_timestamp [String | Integer] integer or hex number
      # @param fast_time [String | Integer] integer or hex number
      # @param ibd [Boolean]
      # @param inflight_blocks_count [String | Integer] integer or hex number
      # @param low_time [String | Integer] integer or hex number
      # @param normal_time [String | Integer] integer or hex number
      # @param orphan_blocks_count [String | Integer] integer or hex number
      def initialize(best_known_block_number:, best_known_block_timestamp:, fast_time:, ibd:, inflight_blocks_count:, low_time:, normal_time:, orphan_blocks_count:)
        @best_known_block_number = Utils.to_int(best_known_block_number)
        @best_known_block_timestamp = Utils.to_int(best_known_block_timestamp)
        @fast_time = Utils.to_int(fast_time)
        @ibd = ibd
        @inflight_blocks_count = Utils.to_int(inflight_blocks_count)
        @low_time = Utils.to_int(low_time)
        @normal_time = Utils.to_int(normal_time)
        @orphan_blocks_count = Utils.to_int(orphan_blocks_count)
      end

      def to_h
        {
          best_known_block_number: Utils.to_hex(best_known_block_number),
          best_known_block_timestamp: Utils.to_hex(best_known_block_timestamp),
          fast_time: Utils.to_hex(fast_time),
          ibd: ibd,
          inflight_blocks_count: Utils.to_hex(inflight_blocks_count),
          low_time: Utils.to_hex(low_time),
          normal_time: Utils.to_hex(normal_time),
          orphan_blocks_count: Utils.to_hex(orphan_blocks_count)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          best_known_block_number: hash[:best_known_block_number],
          best_known_block_timestamp: hash[:best_known_block_timestamp],
          fast_time: hash[:fast_time],
          ibd: hash[:ibd],
          inflight_blocks_count: hash[:inflight_blocks_count],
          low_time: hash[:low_time],
          normal_time: hash[:normal_time],
          orphan_blocks_count: hash[:orphan_blocks_count]
        )
      end
    end
  end
end
