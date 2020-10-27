# frozen_string_literal: true

module CKB
  module Types
    class LocalNode
      attr_accessor :version, :node_id, :active, :addresses, :protocols, :connections

      # @param version [String]
      # @param node_id [String]
      # @param active [Boolean]
      # @param addresses [AddressInfo]
      # @protocols [LocalNodeProtocol]
      # connections [String | Integer] integer or hex number
      def initialize(version:, node_id:, active:, addresses:, protocols:, connections:)
        @version = version
        @node_id = node_id
        @active = active
        @addresses = addresses
        @protocols = protocols
        @connections = Utils.to_int(connections)
      end

      def to_h
        {
          version: version,
          node_id: node_id,
          active: active,
          addresses: addresses.map(&:to_h),
          protocols: protocols.map(&:to_h),
          connections: Utils.to_hex(connections)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          version: hash[:version],
          node_id: hash[:node_id],
          active: hash[:active],
          addresses: hash[:addresses].map { |addr| AddressInfo.from_h(addr) },
          protocols: hash[:protocols].map { |protocol| LocalNodeProtocol.from_h(protocol) },
          connections: hash[:connections]
        )
      end
    end
  end
end
