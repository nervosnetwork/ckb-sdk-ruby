# frozen_string_literal: true

module CKB
  module Serializers
    class Uint64Serializer
      # @param value [String]
      def initialize(value)
        @value = value
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :value

      def layout
        body
      end

      def body
        [value.to_i].pack("Q<").unpack1("H*")
      end
    end
  end
end