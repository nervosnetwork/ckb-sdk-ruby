# frozen_string_literal: true

module CKB
  module Serializers
    class OutputDataSerializer
      include BaseSerializer

      # @param output_data [String]
      def initialize(output_data)
        if output_data
          output_data = output_data.start_with?("0x") ? output_data[2..-1] : output_data
        else
          output_data = ""
        end
        items = output_data.scan(/../)
        @bytes_serializer = FixVecSerializer.new(items, ByteSerializer)
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize[2..-1]
      end
    end
  end
end
