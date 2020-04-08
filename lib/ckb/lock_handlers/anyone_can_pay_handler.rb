module CKB
  module LockHandlers
    class AnyoneCanPayHandler < SingleSignHandler
      attr_reader :anyone_can_pay_cell_dep

      def initialize(anyone_can_pay_tx_hash = "0xeba5986c50e7e8215c2acd6501150cab1346119f42f4d7870bfadd5bfdf7fe57", index = 0)
        # This is my locally deployed anyone can pay cell dep. This cell dep info will be replaced after the real anyone can pay lock script deployed on mainnet in the future
        @anyone_can_pay_cell_dep = CKB::Types::CellDep.new(out_point: CKB::Types::OutPoint.new(tx_hash: anyone_can_pay_tx_hash, index: index), dep_type: "dep_group")
      end

      def generate(cell_meta:, tx_generator:, context:)
        tx_generator.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
        tx_generator.transaction.cell_deps << anyone_can_pay_cell_dep unless tx_generator.transaction.cell_deps.map(&:to_h).include?(anyone_can_pay_cell_dep.to_h)
        if context.nil?
          witness = "0x"
        else
          witness =
            if tx_generator.cell_metas.any? { |inner_cell_meta| inner_cell_meta.output.lock.compute_hash == cell_meta.output.lock.compute_hash }
              CKB::Types::Witness.new
            else
              CKB::Types::Witness.new(lock: "0x#{'0' * 130}")
            end
        end
        tx_generator.transaction.witnesses << witness
        tx_generator.cell_metas << cell_meta
      end
    end
  end
end
