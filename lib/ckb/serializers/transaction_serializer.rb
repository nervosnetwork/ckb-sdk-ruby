# frozen_string_literal: true

module CKB
  module Serializers
    class TransactionSerializer
      include TableSerializer

      # @param transaction [CKB::Types::Transaction]
      def initialize(transaction)
        @raw_serializer = RawTransactionSerializer.new(transaction)
        @witnesses_serializer = DynVecSerializer.new(transaction.witnesses, WitnessSerializer)
        @items_count = 2
      end

      private

      attr_reader :raw_serializer, :witnesses_serializer, :items_count

      def body
        raw_layout + witnesses_layout
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + raw_capacity

        [offset0, offset1]
      end

      def raw_layout
        raw_serializer.serialize[2..-1]
      end

      def raw_capacity
        raw_serializer.capacity
      end

      def witnesses_layout
        witnesses_serializer.serialize[2..-1]
      end
    end
  end
end
