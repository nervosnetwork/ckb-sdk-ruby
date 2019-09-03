# frozen_string_literal: true

module CKB
  module Serializers
    class ByteSerializer
      include BaseSerializer

      # @param value [String]
      def initialize(value)
        @value = value || ""
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
