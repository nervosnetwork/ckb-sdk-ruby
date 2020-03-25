# frozen_string_literal: true

module CKB
  class TransactionGenerator
    attr_accessor :transaction, :cell_metas

    def initialize(hash)
      @transaction = CKB::Types::Transaction.from_h(hash)
      @cell_metas = []
    end

    # Build unsigned transaction
    # @param collector [Enumerator] `CellMeta` enumerator
    # @param contexts [hash], key: input lock script, value: tx generating context
    # @param fee_rate [Integer] Default 1 shannon / transaction byte
    def generate(collector:, contexts:, fee_rate: 1)
      change_output_index = transaction.outputs.find_index { |output| output.capacity == 0 }

      collector.each do |cell_meta|
        lock_script = cell_meta.output.lock
        type_script = cell_meta.output.type
        lock_handler = CKB::Config.instance.lock_handler(lock_script)
        lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script])
        if type_script
          type_handler = CKB::Config.instance.type_handler(type_script)
          type_handler.generate(cell_meta: cell_meta, tx_generator: self)
        end

        return if collected_enough_assets?(change_output_index, fee_rate)
      end

      raise "collected inputs not enough"
    end

    # @param contexts [Hash], key: input lock script, value: tx signature context
    def sign(contents)
      self.cell_metas.each do |cell_meta|
        lock_script = cell_meta.output.lock
        lock_handler = CKB::Config.instance.lock_handler(lock_script)
        if context = contents[lock_script]
          lock_handler.sign(cell_meta: cell_meta, tx_generator: self, context: context)
        end
      end
    end

    def collected_enough_assets?(change_output_index, fee_rate)
      fee = transaction.serialized_size_in_block * fee_rate
      change_capacity = inputs_capacity - transaction.outputs_capacity - fee
      if change_output_index
        change_output = transaction.outputs[change_output_index]
        change_output_data = transaction.outputs_data[change_output_index]
        change_output_occupied_capacity = CKB::Utils.byte_to_shannon(change_output.calculate_bytesize(change_output_data))
        if change_capacity >= change_output_occupied_capacity
          change_output.capacity = change_capacity
          true
        else
          false
        end
      else
        if change_capacity > 0
          raise "cannot find change output"
        elsif change_capacity == 0
          true
        else
          false
        end
      end
    end

    def inputs_capacity
      cell_metas.map { |cell_meta| cell_meta.output.capacity }.sum
    end
  end
end
