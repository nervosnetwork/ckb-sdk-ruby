# frozen_string_literal: true

module CKB
  module Serializers
    class OutputDataSerializer
      include BaseSerializer

      # @param output_data [String]
      def initialize(output_data)
        items = output_data.delete_prefix("0x").scan(/../)
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
