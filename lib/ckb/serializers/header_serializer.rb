# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderSerializer
      include StructSerializer

      # @param input [CKB::Types::BlockHeader]
      def initialize(header)
        @raw_header_serializer = RawHeaderSerializer.new(header)
        @nonce_serializer = Uint128Serializer.new(header.nonce)
      end

      private

      attr_reader :raw_header_serializer, :nonce_serializer

      def body
        raw_header_layout + nonce_layout
      end

      def raw_header_layout
        raw_header_serializer.serialize[2..-1]
      end

      def nonce_layout
        nonce_serializer.serialize[2..-1]
      end
    end
  end
end
