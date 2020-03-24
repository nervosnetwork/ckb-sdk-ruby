# frozen_string_literal: true
require "secp256k1"

module CKB
  class SingleSignHandler
    def self.generate(cell_meta:, tx_generator:, context:)
      tx_generator.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
      cell_dep = CKB::Config.instance.standard_secp256k1_blake160_sighash_all_cell_dep
      tx_generator.transaction.cell_deps << cell_dep unless tx_generator.transaction.cell_deps.include?(cell_dep)
      witness =
        if tx_generator.cell_metas.any? { |inner_cell_meta| inner_cell_meta.output.lock == cell_meta.output.lock }
          CKB::Types::Witness.new
        else
          CKB::Types::Witness.new(lock: "0x#{'0' * 130}")
        end
      tx_generator.transaction.witnesses << witness
      tx_generator.cell_metas << cell_meta
    end
  end
end
