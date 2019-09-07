# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointSerializer
      include StructSerializer

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
        index_serializer.serialize[2..-1]
      end

      def tx_hash_layout
        tx_hash_serializer.serialize[2..-1]
      end
    end
  end
end
