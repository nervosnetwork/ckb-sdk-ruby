# frozen_string_literal: true

module CKB
  module TypeHandlers
    class SudtHandler
      attr_reader :sudt_cell_dep

      def initialize(sudt_tx_hash, index)
        @sudt_cell_dep = CKB::Types::CellDep.new(out_point: CKB::Types::OutPoint.new(tx_hash: sudt_tx_hash, index: index))
      end

      def generate(cell_meta: nil, tx_generator:, context: nil)
        tx_generator.transaction.cell_deps << sudt_cell_dep unless tx_generator.transaction.cell_deps.include?(sudt_cell_dep)
      end

      def sign(cell_meta: nil, tx_generator:, context: nil); end
    end
  end
end
