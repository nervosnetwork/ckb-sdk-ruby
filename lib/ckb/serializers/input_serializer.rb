# frozen_string_literal: true

module CKB
  module Serializers
    class InputSerializer
      include TableSerializer

      # @param input [CKB::Types::Input]
      def initialize(input)
        @out_point_serializer = OutPointSerializer.new(input.previous_output)
        @since_serializer = SinceSerializer.new(input.since)
        @items_count = 2
      end

      private

      attr_reader :out_point_serializer, :since_serializer, :items_count

      def body
        out_point_layout + since_layout
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + out_point_serializer.capacity

        [offset0, offset1]
      end

      def since_layout
        since_serializer.serialize
      end

      def out_point_layout
        out_point_serializer.serialize
      end
    end
  end
end
