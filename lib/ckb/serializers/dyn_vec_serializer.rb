module CKB
  module Serializers
    module DynVecSerializer
      include BaseSerializer

      UINT32_CAPACITY = 4

      private

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
