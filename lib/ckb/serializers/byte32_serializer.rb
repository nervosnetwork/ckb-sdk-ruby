# frozen_string_literal: true

module CKB
  module Serializers
    class Byte32Serializer
      include BaseSerializer

      # @param value [String]
      def initialize(value)
        @value = value.delete_prefix("0x")
      end

      private

      attr_reader :value

      def layout
        body
      end

      def body
        items = value.delete_prefix("0x").scan(/../)
        items.map { |item| ByteSerializer.new(item).serialize }.join("")
      end
    end
  end
end
