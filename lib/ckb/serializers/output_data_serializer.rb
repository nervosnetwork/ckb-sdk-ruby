# frozen_string_literal: true

module CKB
  module Serializers
    class OutputDataSerializer
      include BaseSerializer

      # @param output_data [String]
      def initialize(output_data)
        @item = if output_data
                  output_data.start_with?("0x") ? output_data[2..-1] : output_data
                else
                  ""
                end
        @items_count = item.size / 2
      end

      private

      attr_reader :bytes_serializer, :item, :items_count

      def header
        [items_count].pack("V").unpack("H*").first
      end

      def body
        item
      end

      def layout
        header + body
      end
    end
  end
end
