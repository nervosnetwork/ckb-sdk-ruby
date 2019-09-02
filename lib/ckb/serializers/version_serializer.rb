# frozen_string_literal: true

module CKB
  module Serializers
    class VersionSerializer
      # @param version [String]
      def initialize(version)
        @uint32_serializer = Uint32Serializer.new(version)
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :uint32_serializer

      def layout
        body
      end

      def body
        uint32_serializer.serialize
      end
    end
  end
end