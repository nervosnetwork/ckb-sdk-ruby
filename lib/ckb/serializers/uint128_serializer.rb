# frozen_string_literal: true

module CKB
  module Serializers
    class Uint128Serializer
      include BaseSerializer

      # @param value [String]
      def initialize(value)
        @value = value
      end

      private

      attr_reader :value

      def layout
        body
      end

      def body
        values = [value & 0xFFFFFFFFFFFFFFFF, (value >> 64) & 0xFFFFFFFFFFFFFFFF]
        values.pack("Q<Q<").unpack1("H*")
      end
    end
  end
end
