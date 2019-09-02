# frozen_string_literal: true

module CKB
  module Serializers
    class CapacitySerializer
      # @param capacity [String]
      def initialize(capacity)
        @uint64_serializer = Uint64Serializer.new(capacity)
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :uint64_serializer

      def layout
        body
      end

      def body
        uint64_serializer.serialize
      end
    end
  end
end