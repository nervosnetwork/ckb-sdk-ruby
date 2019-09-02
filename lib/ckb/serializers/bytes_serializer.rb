# frozen_string_literal: true

module CKB
  module Serializers
    class BytesSerializer
      include FixVecSerializer

      # @param value [String]
      def initialize(value)
        @value = value.delete_prefix("0x")
        @items_count = [body].pack("H*").bytesize
      end

      private

      attr_reader :value, :items_count

      def item_layouts
        return "" if value.nil?

        value
      end
    end
  end
end
