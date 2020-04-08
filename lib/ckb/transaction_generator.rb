# frozen_string_literal: true

module CKB
  class TransactionGenerator
    attr_accessor :transaction, :cell_metas
    attr_reader :api

    def initialize(api, transaction)
      @api = api
      @transaction = transaction
      @cell_metas = []
    end

    # Build unsigned transaction
    # @param collector [Enumerator] `CellMeta` enumerator
    # @param contexts [hash], key: input lock script hash, value: tx generating context
    # @param fee_rate [Integer] Default 1 shannon / transaction byte
    def generate(collector:, contexts:, fee_rate: 1)
      transaction.outputs.each_with_index do |output, index|
        if type_script = output.type
          if type_handler = CKB::Config.new(api).type_handler(type_script)
            output_data = transaction.outputs_data[index]
            cell_meta = CKB::CellMeta.new(api: api, out_point: nil, output: output, output_data_len: Utils.hex_to_bin(output_data).bytesize, cellbase: false)
            cell_meta.output_data = output_data
            type_handler.generate(cell_meta: cell_meta, tx_generator: self)
          end
        end
      end

      change_output_index = transaction.outputs.rindex { |output| output.capacity == 0 }

      collector.each do |cell_meta|
        lock_script = cell_meta.output.lock
        type_script = cell_meta.output.type
        lock_handler = CKB::Config.new(api).lock_handler(lock_script)
        lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script.compute_hash])
        if type_script
          type_handler = CKB::Config.new(api).type_handler(type_script)
          type_handler.generate(cell_meta: cell_meta, tx_generator: self)
        end

        return if enough_capacity?(change_output_index, fee_rate)
      end

      raise "collected inputs not enough"
    end

    # @param contexts [Hash], key: input lock script hash, value: tx signature context
    def sign(contexts)
      cell_metas.each do |cell_meta|
        lock_script = cell_meta.output.lock
        lock_handler = CKB::Config.new(api).lock_handler(lock_script)
        if context = contexts[lock_script.compute_hash]
          lock_handler.sign(cell_meta: cell_meta, tx_generator: self, context: context)
        end
      end
    end

    def enough_capacity?(change_output_index, fee_rate)
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
