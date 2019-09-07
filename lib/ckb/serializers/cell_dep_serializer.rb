# frozen_string_literal: true

module CKB
  module Serializers
    class CellDepSerializer
      include StructSerializer

      # @param cell_dep [CKB::Types::CellDep]
      def initialize(cell_dep)
        @out_point_serializer = OutPointSerializer.new(cell_dep.out_point)
        @dep_type_serializer = DepTypeSerializer.new(cell_dep.dep_type)
      end

      private

      attr_reader :out_point_serializer, :dep_type_serializer

      def body
        out_point_layout + dep_type_layout
      end

      def out_point_layout
        out_point_serializer.serialize[2..-1]
      end

      def dep_type_layout
        dep_type_serializer.serialize[2..-1]
      end
    end
  end
end
