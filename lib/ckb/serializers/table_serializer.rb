module CKB
  module Serializers
    module TableSerializer
      include BaseSerializer

      UINT32_CAPACITY = 4
      UINT64_CAPACITY = 8
      BYTE32_CAPACITY = 32
      SCRIPT_HASH_TYPE_CAPACITY = 1

      private

      def layout
        header + body
      end

      def header
        full_length_hex + offsets_hex
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
