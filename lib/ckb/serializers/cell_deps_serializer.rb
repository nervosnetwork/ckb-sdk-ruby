# frozen_string_literal: true

module CKB
  module Serializers
    class CellDepsSerializer
      # @param cell_deps [CKB::Types::CellDep[]]
      def initialize(cell_deps)
        @cell_deps = cell_deps
        @items_count = cell_deps.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :cell_deps, :items_count

      def layout
        if items_count == 0
          [uint32_capacity].pack("V").unpack1("H*")
        else
          header + body
        end
      end

      def header
        full_length_hex + offsets_hex
      end

      def body
        cell_dep_layouts
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offsets = [offset0]
        cell_deps.each.with_index(1) do |_cell_dep, index|
          break if cell_deps[index].nil?

          cell_dep = cell_deps[index - 1]
          offsets << offset0 += CellDepSerializer.new(cell_dep).capacity
        end

        offsets
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def offsets_hex
        offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
      end

      def body_capacity
        [cell_dep_layouts].pack("H*").bytesize
      end

      def cell_dep_layouts
        return "" if items_count == 0

        cell_deps.map { |cell_dep| CellDepSerializer.new(cell_dep).serialize }.join("")
      end

      def uint32_capacity
        4
      end
    end
  end
end