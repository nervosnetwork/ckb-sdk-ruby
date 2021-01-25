# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointTxHashSerializer
      include BaseSerializer

      # @param tx_hash [String]
      def initialize(tx_hash)
        @item = if tx_hash
                  tx_hash.start_with?("0x") ? tx_hash[2..-1] : tx_hash
                else
                  ""
                end
      end

      private

      attr_reader :item

      def layout
        body
      end

      def body
        item
      end
    end
  end
end
