# frozen_string_literal: true

module CKB
  module Serializers
    class WitnessSerializer
      include BaseSerializer

      # @param witness [String]
      def initialize(witness)
        @item = if witness
                  witness.start_with?("0x") ? witness[2..-1] : witness
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
