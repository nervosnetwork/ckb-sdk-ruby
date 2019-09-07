# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderDepSerializer
      include BaseSerializer

      # @param header_dep [String]
      def initialize(header_dep)
        @byte32_serializer = Byte32Serializer.new(header_dep)
      end

      private

      attr_reader :byte32_serializer

      def layout
        body
      end

      def body
        byte32_serializer.serialize[2..-1]
      end
    end
  end
end
