# frozen_string_literal: true

module CKB
  module Types
    class PeerSyncState
      attr_accessor :best_known_header_hash, :best_known_header_number, :last_common_header_hash, :last_common_header_number, :unknown_header_list_size, :inflight_count, :can_fetch_count

      # @param best_known_header_hash [String] 0x
      # @param best_known_header_number [String | Integer] integer or hex number
      # @param last_common_header_hash [String] 0x
      # @param last_common_header_number [String | Integer] integer or hex number
      # @param unknown_header_list_size [String | Integer] integer or hex number
      # @param inflight_count [String | Integer] integer or hex number
      # @param can_fetch_count [String | Integer] integer or hex number
      def initialize(best_known_header_hash:, best_known_header_number:, last_common_header_hash:, last_common_header_number:, unknown_header_list_size:, inflight_count:, can_fetch_count:)
        @best_known_header_hash = best_known_header_hash
        @best_known_header_number = Utils.to_int(best_known_header_number)
        @last_common_header_hash = last_common_header_hash
        @last_common_header_number = Utils.to_int(last_common_header_number)
        @unknown_header_list_size = Utils.to_int(unknown_header_list_size)
        @inflight_count = Utils.to_int(inflight_count)
        @can_fetch_count = Utils.to_int(can_fetch_count)
      end

      def to_h
        {
            best_known_header_hash: best_known_header_hash,
            best_known_header_number: Utils.to_hex(best_known_header_number),
            last_common_header_hash: last_common_header_hash,
            last_common_header_number: Utils.to_hex(last_common_header_number),
            unknown_header_list_size: Utils.to_hex(unknown_header_list_size),
            inflight_count: Utils.to_hex(inflight_count),
            can_fetch_count: Utils.to_hex(can_fetch_count)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
            best_known_header_hash: hash[:best_known_header_hash],
            best_known_header_number: hash[:best_known_header_number],
            last_common_header_hash: hash[:last_common_header_hash],
            last_common_header_number: hash[:last_common_header_number],
            unknown_header_list_size: hash[:unknown_header_list_size],
            inflight_count: hash[:inflight_count],
            can_fetch_count: hash[:can_fetch_count],
        )
      end
    end
  end
end
