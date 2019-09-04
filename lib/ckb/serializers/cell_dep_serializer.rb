# frozen_string_literal: true

module CKB
  module Serializers
    class CellDepSerializer
      include TableSerializer

      # @param cell_dep [CKB::Types::CellDep]
      def initialize(cell_dep)
        @out_point_serializer = OutPointSerializer.new(cell_dep.out_point)
        @dep_type_serializer = DepTypeSerializer.new(cell_dep.dep_type)
        @items_count = 2
      end

      private

      attr_reader :out_point_serializer, :dep_type_serializer, :items_count

      def body
        out_point_layout + dep_type_layout
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + out_point_serializer.capacity

        [offset0, offset1]
      end

      def out_point_layout
        out_point_serializer.serialize
      end

      def dep_type_layout
        dep_type_serializer.serialize
      end
    end
  end
end
