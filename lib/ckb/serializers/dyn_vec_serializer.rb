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
        if items_count == 0
          [UINT32_CAPACITY].pack("V").unpack1("H*")
        else
          header + body
        end
      end

      def header
        full_length_hex + offsets_hex
      end

      def body
        item_layouts
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        items.each.with_index(1) do |_item, index|
          break if items[index].nil?

          offsets << offset0 += item_serializer.new(items[index - 1]).capacity
        end

        offsets
      end

      def item_layouts
        return "" if items_count == 0

        items.map { |item| item_serializer.new(item).serialize }.join("")
      end

      def full_length_hex
        full_length = (items_count + 1) * UINT32_CAPACITY + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def offsets_hex
        offsets.map { |offset| [offset].pack("V").unpack1("H*") }.join("")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end
    end
  end
end
