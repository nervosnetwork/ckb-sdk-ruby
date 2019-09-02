# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointSerializer
      include TableSerializer

      # @param out_point [CKB::Types::OutPoint]
      def initialize(out_point)
        @tx_hash_serializer = OutPointTxHashSerializer.new(out_point.tx_hash)
        @index_serializer = OutPointIndexSerializer.new(out_point.index)
        @items_count = 2
      end

      private

      attr_reader :tx_hash_serializer, :index_serializer, :items_count

      def body
        tx_hash_layout + index_layout
      end

      def index_layout
        index_serializer.serialize
      end

      def tx_hash_layout
        tx_hash_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + BYTE32_CAPACITY

        [offset0, offset1]
      end
    end
  end
end
