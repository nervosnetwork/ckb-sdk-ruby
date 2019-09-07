# frozen_string_literal: true

module CKB
  module Serializers
    class Byte32Serializer
      include BaseSerializer

      # @param value [String]
      def initialize(value)
        if value
          @value = value.start_with?("0x") ? value[2..-1] : value
        else
          @value = ""
        end
      end

      private

      attr_reader :value

      def layout
        body
      end

      def body
        items = value.scan(/../)
        items.map { |item| ByteSerializer.new(item).serialize[2..-1] }.join("")
      end
    end
  end
end
