# frozen_string_literal: true

module CKB
  module Serializers
    class CellDepSerializer
      # @param cell_dep [CKB::Types::CellDep]
      def initialize(cell_dep)
        @out_point_serializer = OutPointSerializer.new(cell_dep.out_point)
        @dep_type_serializer = DepTypeSerializer.new(cell_dep.dep_type)
        @items_count = 2
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :out_point_serializer, :dep_type_serializer, :items_count

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        out_point_layout + dep_type_layout
      end

      def out_point_layout
        out_point_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offset1 = offset0 + out_point_serializer.capacity

        [offset0, offset1]
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def dep_type_layout
        dep_type_serializer.serialize
      end

      def uint32_capacity
        4
      end
    end
  end
end