# frozen_string_literal: true

module CKB
  module Serializers
    class BlockSerializer
      include TableSerializer

      # @param block [CKB::Types::Block]
      def initialize(block)
        @header_serializer = HeaderSerializer.new(block.header)
        @uncles_serializer = DynVecSerializer.new(block.uncles, UncleBlockSerializer)
        @transactions_serializer = DynVecSerializer.new(block.transactions, TransactionSerializer)
        @proposals_serializer = FixVecSerializer.new(block.proposals, ProposalShortIdSerializer)
        @extension_serializer = BytesSerializer.new(block.extension)
        @items_count = 5
      end

      private

      attr_reader :header_serializer, :uncles_serializer, :transactions_serializer, :proposals_serializer, :extension_serializer, :items_count

      def body
        header_layout + uncles_layout + transactions_layout + proposals_layout + extension_layout
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + header_capacity
        offset2 = offset1 + uncles_capacity
        offset3 = offset2 + transactions_capacity
        offset4 = offset3 + proposals_capacity
        [offset0, offset1, offset2, offset3, offset4]
      end

      def header_layout
        header_serializer.serialize[2..-1]
      end

      def uncles_layout
        uncles_serializer.serialize[2..-1]
      end

      def transactions_layout
        transactions_serializer.serialize[2..-1]
      end

      def proposals_layout
        proposals_serializer.serialize[2..-1]
      end

      def extension_layout
        extension_serializer.serialize[2..-1]
      end

      def header_capacity
        header_serializer.capacity
      end

      def uncles_capacity
        uncles_serializer.capacity
      end

      def transactions_capacity
        transactions_serializer.capacity
      end

      def proposals_capacity
        proposals_serializer.capacity
      end
    end
  end
end
