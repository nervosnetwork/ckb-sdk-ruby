module CKB
  class MultiSignHandler
    # @param context [Array] multisig script, format: [S, R, M, N, blake160(pubkey1), blake160(pubkey2), ...]
    def self.generate(api:, cell_meta:, tx_generator:, context:)
      tx_generator.transaction.inputs << CKB::Types::Input.new(since: 0, previous_output: cell_meta.out_point)
      cell_dep = CKB::Config.new(api).standard_secp256k1_blake160_multisig_all
      tx_generator.transaction.cell_deps << cell_dep unless tx_generator.transaction.cell_deps.include?(cell_dep)
      witness =
        if tx_generator.cell_metas.any? { |inner_cell_meta| inner_cell_meta.output.script.compute_hash == cell_meta.output.script.compute_hash }
          CKB::Types::Witness.new
        else
          # build witness with signature placeholder
          empty_signature = Utils.bin_to_hex(("\x00" * 65) * context[2])
          emptied_witness =
            CKB::Utils.hex_concat(
              CKB::Utils.bin_to_hex(
                context[0, 4].pack("CCCC") +
                context[4..-1].map do |pubkey|
                  CKB::Utils.hex_to_bin(pubkey)
                end.reduce(&:+)
              ), empty_signature
            )
          CKB::Types::Witness.new(lock: emptied_witness)
        end
        tx_generator.transaction.witnesses << witness
        tx_generator.cell_metas << cell_meta
    end

    # @param context [Array] private key string in raw format
    def self.sign(cell_meta:, tx_generator:, context:)
      lock_script = cell_meta.output.lock
      cell_meta_index = tx_generator.cell_metas.find_index { |inner_cell_meta| inner_cell_meta == cell_meta }
      grouped_indexes = tx_generator.cell_metas.map.with_index { |inner_cell_meta, index| index if inner_cell_meta.output.lock.compute_hash == lock_script.compute_hash }.compact

      if cell_meta_index == grouped_indexes.first
        transaction = tx_generator.transaction
        witness = tx_generator.transaction.witnesses[cell_meta_index]
        blake2b = CKB::Blake2b.new
        blake2b.update(Utils.hex_to_bin(transaction.compute_hash))
        binary_witness_lock = Utils.hex_to_bin(witness.lock)
        # 2 / 3 is the position of multisig script‘s M and N in witness lock, it is calculated by hand
        required_signatures = binary_witness_lock[2].unpack("C")[0]
        total_public_keys = binary_witness_lock[3].unpack("C")[0]
        grouped_indexes.each do |index|
          witness_dup = witness.dup
          signature_offset_in_serialized_witness = 24 + 20 * total_public_keys
          binary_witness = Utils.hex_to_bin(CKB::Serializers::WitnessArgsSerializer.new(witness_dup).serialize)
          if index == cell_meta_index
            binary_witness[signature_offset_in_serialized_witness, 65 * required_signatures] = ("\x00" * 65) * required_signatures
          end
          binary_witness_size = binary_witness.bytesize
          blake2b.update([binary_witness_size].pack("Q<"))
          blake2b.update(binary_witness)
        end
        message = blake2b.hexdigest

        context.map do |private_key|
          private_key = CKB::Key.new(private_key) unless private_key.instance_of?(CKB::Key)
          signature = private_key.sign_recoverable(message)
          signature_offset_in_witness_lock = 4 + 20 * total_public_keys
          binary_witness_lock[signature_offset_in_witness_lock..-1].split("").each_slice(65).with_index do |inner_signature, index|
            if inner_signature.join("") == ("\x00" * 65)
              start_index = signature_offset_in_witness_lock + 65 * index
              end_index = start_index + 65
              binary_witness_lock[start_index...end_index] = CKB::Utils.hex_to_bin(signature)
              witness.lock = CKB::Utils.bin_to_hex(binary_witness_lock)
              break
            end
          end
        end
      end
    end
  end
end
