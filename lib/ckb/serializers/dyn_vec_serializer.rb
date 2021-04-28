# frozen_string_literal: true

module CKB
  module Serializers
    class DynVecSerializer
      include BaseSerializer

      UINT32_CAPACITY = 4

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
        full_length_hex + offsets_hex
      end

      def body
        item_layouts
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = []
        previous_offset = offset0
        items.each.with_index do |_item, index|
          offsets << previous_offset && next if index.zero?

          new_offset = previous_offset + item_serializer.new(items[index - 1]).capacity
          offsets << new_offset
          previous_offset = new_offset
        end

        offsets
      end

      def item_layouts
        return "" if items_count.zero?

        items.map { |item| item_serializer.new(item).serialize[2..-1] }.join("")
      end

      def full_length_hex
        full_length = (items_count + 1) * UINT32_CAPACITY + body_capacity
        [full_length].pack("V").unpack("H*").first
      end

      def offsets_hex
        offsets.map { |offset| [offset].pack("V").unpack("H*").first }.join("")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end
    end
  end
end
