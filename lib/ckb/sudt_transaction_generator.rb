# frozen_string_literal: true

module CKB
  class SudtTransactionGenerator < TransactionGenerator
    attr_accessor :is_issuer

    def enough_capacity?(change_output_index, fee_rate)
      if super(change_output_index, fee_rate)
        if is_issuer
          true
        else
          inputs_sudt_amount = cell_metas.select { |cell_meta| !cell_meta.output.type.nil? }.map { |cell_meta| CKB::Utils.sudt_amount!(cell_meta.output_data) }.sum
          outputs_sudt_amount = transaction.outputs_data.map { |output_data| CKB::Utils.sudt_amount!(output_data) }.sum
          change_sudt_amount = inputs_sudt_amount - outputs_sudt_amount
          if change_sudt_amount >= 0
            data = CKB::Utils.generate_sudt_amount(change_sudt_amount)
            transaction.outputs_data[change_output_index] = data

            true
          end
        end
      end
    end
  end
end
