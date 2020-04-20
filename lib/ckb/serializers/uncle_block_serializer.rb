# frozen_string_literal: true

module CKB
  module Serializers
    class UncleBlockSerializer
      include TableSerializer

      # @param block [CKB::Types::Uncle]
      def initialize(uncle_block)
        @header_serializer = HeaderSerializer.new(uncle_block.header)
        @proposals_serializer = ProposalsSerializer.new(uncle_block.proposals)

        @items_count = 2
      end

      private

      attr_reader :header_serializer, :proposals_serializer

      def body
        header_layout + proposals_layout
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + header_capacity

        [offset0, offset1]
      end

      def header_layout
        header_serializer.serialize[2..-1]
      end

      def proposals_layout
        proposals_serializer.serialize[2..-1]
      end
    end
  end
end
