# frozen_string_literal: true

module CKB
  module Serializers
    class ArgSerializer
      include BaseSerializer

      # @param arg [String]
      def initialize(arg)
        items = arg.delete_prefix("0x").scan(/../)
        @bytes_serializer = FixVecSerializer.new(items, ByteSerializer)
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize
      end
    end
  end
end
