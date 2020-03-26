# frozen_string_literal: true
require "secp256k1"

module CKB
  class SingleSignHandler
    def self.generate(api:, cell_meta:, tx_generator:, context:)
      tx_generator.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
      cell_dep = CKB::Config.new(api).standard_secp256k1_blake160_sighash_all_cell_dep
      tx_generator.transaction.cell_deps << cell_dep unless tx_generator.transaction.cell_deps.include?(cell_dep)
      witness =
        if tx_generator.cell_metas.any? { |inner_cell_meta| inner_cell_meta.output.lock.compute_hash == cell_meta.output.lock.compute_hash }
          CKB::Types::Witness.new
        else
          CKB::Types::Witness.new(lock: "0x#{'0' * 130}")
        end
      tx_generator.transaction.witnesses << witness
      tx_generator.cell_metas << cell_meta
    end

    def self.sign(cell_meta:, tx_generator:, context:)
      lock_script = cell_meta.output.lock
      cell_meta_index = tx_generator.cell_metas.find_index { |inner_cell_meta| inner_cell_meta == cell_meta  }
      grouped_indexes = tx_generator.cell_metas.map.with_index { |inner_cell_meta, index| index if inner_cell_meta.output.lock.compute_hash == lock_script.compute_hash }.compact
      uncoverd_witness_index = tx_generator.transaction.inputs.size
      while uncoverd_witness_index < tx_generator.transaction.witnesses.size
        grouped_indexes << tx_generator.transaction.witnesses[uncoverd_witness_index]
        uncoverd_witness_index += 1
      end

      if cell_meta_index == grouped_indexes.first
        transaction = tx_generator.transaction
        blake2b = CKB::Blake2b.new
        blake2b.update(Utils.hex_to_bin(transaction.compute_hash))
        grouped_indexes.each do |index|
          witness = tx_generator.transaction.witnesses[index]
          binary_witness = Utils.hex_to_bin(CKB::Serializers::WitnessArgsSerializer.new(witness).serialize)
          binary_witness_size = binary_witness.bytesize
          blake2b.update([binary_witness_size].pack("Q<"))
          blake2b.update(binary_witness)
        end
        message = blake2b.hexdigest
        private_key = CKB::Key.new(context)
        tx_generator.transaction.witnesses[cell_meta_index].lock = private_key.sign_recoverable(message)
      end
    end
  end
end
