# frozen_string_literal: true

module CKB
  module Serializers
    class BytesOptSerializer
      include BaseSerializer

      # @param bytes [String]
      def initialize(bytes = "")
        @item = if bytes
                  bytes.start_with?("0x") ? bytes[2..-1] : bytes
                else
                  ""
                end
        @items_count = item.size / 2
      end

      private

      attr_reader :bytes, :item, :items_count

      def header
        [items_count].pack("V").unpack("H*").first
      end

      def body
        item
      end

      def layout
        if !item.empty?
          header + body
        else
          ""
        end
      end
    end
  end
end
