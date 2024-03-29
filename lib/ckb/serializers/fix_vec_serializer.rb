# frozen_string_literal: true

module CKB
  module Serializers
    class FixVecSerializer
      include BaseSerializer

      def initialize(items, item_serializer)
        @items = items
        @items_count = items.count
        @item_serializer = item_serializer
      end

      private

      attr_reader :items, :items_count, :item_serializer

      def layout
        header + body
      end

      def header
        [items_count].pack("V").unpack("H*").first
      end

      def body
        item_layouts
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def item_layouts
        return "" if items_count.zero?

        items.map { |item| item_serializer.new(item).serialize[2..-1] }.join("")
      end
    end
  end
end
