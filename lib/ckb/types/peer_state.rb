# frozen_string_literal: true

module CKB
  module Types
    class PeerState
      attr_accessor :last_updated, :blocks_in_flight, :peer

      # @param last_updated [String | Integer] timestamp
      # @param block_in_flight [String | Integer] integer or hex number
      # @param peer [String | Integer] integer or hex number
      def initialize(last_updated:, blocks_in_flight:, peer:)
        @last_updated = Utils.to_int(last_updated)
        @blocks_in_flight = Utils.to_int(blocks_in_flight)
        @peer = Utils.to_int(peer)
      end

      def to_h
        {
          last_updated: Utils.to_hex(@last_updated),
          blocks_in_flight: Utils.to_hex(@blocks_in_flight),
          peer: Utils.to_hex(peer)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          last_updated: hash[:last_updated],
          blocks_in_flight: hash[:blocks_in_flight],
          peer: hash[:peer]
        )
      end
    end
  end
end
