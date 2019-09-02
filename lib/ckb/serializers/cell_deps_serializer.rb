# frozen_string_literal: true

module CKB
  module Serializers
    class CellDepsSerializer
      include DynVecSerializer

      # @param cell_deps [CKB::Types::CellDep[]]
      def initialize(cell_deps)
        @cell_deps = cell_deps
        @items_count = cell_deps.count
      end

      private

      attr_reader :cell_deps, :items_count

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        cell_deps.each.with_index(1) do |_cell_dep, index|
          break if cell_deps[index].nil?

          cell_dep = cell_deps[index - 1]
          offsets << offset0 += CellDepSerializer.new(cell_dep).capacity
        end

        offsets
      end

      def item_layouts
        return "" if items_count == 0

        cell_deps.map { |cell_dep| CellDepSerializer.new(cell_dep).serialize }.join("")
      end
    end
  end
end
