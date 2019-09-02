# frozen_string_literal: true

module CKB
  module Serializers
    class BytesSerializer
      # @param value [String]
      def initialize(value)
        @value = value.delete_prefix("0x")
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
        return "" if value.nil?

        header + body
      end

      def header
        items_count = [body].pack("H*").bytesize
        [items_count].pack("V").unpack1("H*")
      end

      def body
        value
      end
    end
  end
end