# frozen_string_literal: true

module CKB
  module Types
    class PeerState
      attr_accessor :last_updated, :blocks_in_flight, :peer

      # @param last_updated [String]
      # @param block_in_flight [String] number
      # @param peer [String] number
      def initialize(last_updated:, blocks_in_flight:, peer:)
        @last_updated = last_updated
        @blocks_in_flight = blocks_in_flight
        @peer = peer
      end

      def to_h
        {
          last_updated: @last_updated,
          blocks_in_flight: @blocks_in_flight,
          peer: peer
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
