# frozen_string_literal: true

module CKB
  class SudtTransactionGenerator < TransactionGenerator
    attr_accessor :is_issuer

    def collected_enough_assets?(change_output_index, fee_rate)
      if super(change_output_index, fee_rate)
        if is_issuer
          true
        else
          inputs_sudt_amount = cell_metas.select { |cell_meta| !cell_meta.output.type.nil? }.map { |cell_meta| sudt_amount(cell_meta.output_data) }.sum
          outputs_sudt_amount = transaction.outputs_data.map { |output_data| sudt_amount(output_data) }.sum
          change_sudt_amount = inputs_sudt_amount - outputs_sudt_amount
          if change_sudt_amount >= 0
            data = [change_sudt_amount].pack("Q<*") + [change_sudt_amount >> 64].pack("Q<*")
            transaction.outputs_data[change_output_index] = CKB::Utils.bin_to_hex(data)

            true
          end
        end
      end
    end

    def sudt_amount(output_data)
      CKB::Utils.hex_to_bin(output_data).reverse.unpack1("B*").to_i(2)
    end
  end
end
