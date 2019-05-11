# frozen_string_literal: true

module CKB
  module Types
    class Peer
      attr_reader :addresses, :is_outbound, :node_id, :version

      # @param addresses [AddressInfo[]]
      # @param is_outbound [Boolean]
      # @param node_id [String]
      # @param version [String]
      def initialize(addresses:, is_outbound:, node_id:, version:)
        @addresses = addresses
        @is_outbound = is_outbound
        @node_id = node_id
        @version = version
      end

      def to_h
        {
          addresses: @addresses,
          is_outbound: @is_outbound,
          node_id: @node_id,
          version: @version
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          addresses: hash[:addresses].map { |addr| AddressInfo.from_h(addr) },
          is_outbound: hash[:is_outbound],
          node_id: hash[:node_id],
          version: hash[:version]
        )
      end
    end
  end
end
