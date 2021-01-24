# frozen_string_literal: true

module CKB
  module Serializers
    class Byte32Serializer
      include BaseSerializer

      # @param value [String]
      def initialize(value)
        @value = if value
                   value.start_with?("0x") ? value[2..-1] : value
                 else
                   ""
                 end
      end

      private

      attr_reader :value

      def layout
        body
      end

      def body
        value
      end
    end
  end
end
