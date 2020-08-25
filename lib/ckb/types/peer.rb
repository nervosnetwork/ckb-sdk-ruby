# frozen_string_literal: true

module CKB
  module Types
    class Peer
      attr_accessor :addresses, :is_outbound, :node_id, :version, :connected_duration, :last_ping_duration, :protocols, :sync_state

      # @param addresses [AddressInfo[]]
      # @param is_outbound [Boolean]
      # @param node_id [String]
      # @param version [String]
      # @param connected_duration [String | Integer] integer or hex number
      # @param last_ping_duration [String | Integer] integer or hex number
      # @param protocols [String[Hash]]
      # @param sync_state [PeerSyncState]
      def initialize(addresses:, is_outbound:, node_id:, version:, connected_duration:, last_ping_duration:, protocols:, sync_state:)
        @addresses = addresses
        @is_outbound = is_outbound
        @node_id = node_id
        @version = version
        @connected_duration = connected_duration
        @last_ping_duration = last_ping_duration
        @protocols = protocols
        @sync_state = sync_state
      end

      def to_h
        {
          addresses: @addresses.map(&:to_h),
          is_outbound: @is_outbound,
          node_id: @node_id,
          version: @version,
          connected_duration: Utils.to_hex(@connected_duration),
          last_ping_duration: Utils.to_hex(@last_ping_duration),
          protocols: @protocols,
          sync_state: @sync_state.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          addresses: hash[:addresses].map { |addr| AddressInfo.from_h(addr) },
          is_outbound: hash[:is_outbound],
          node_id: hash[:node_id],
          version: hash[:version],
          connected_duration: hash[:connected_duration],
          last_ping_duration: hash[:last_ping_duration],
          protocols: hash[:protocols],
          sync_state: PeerSyncState.from_h(hash[:sync_state])
        )
      end
    end
  end
end
