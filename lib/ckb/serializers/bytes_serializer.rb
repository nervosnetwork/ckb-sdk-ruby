# frozen_string_literal: true

module CKB
  module Serializers
    class BytesSerializer
      include BaseSerializer

      # @param arg [String]
      def initialize(arg)
        @item = if arg
                  arg.start_with?("0x") ? arg[2..-1] : arg
                else
                  ""
                end
        @items_count = item.size / 2
      end

      private

      attr_reader :item, :items_count

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
