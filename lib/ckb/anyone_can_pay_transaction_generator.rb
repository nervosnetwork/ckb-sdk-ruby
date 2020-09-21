# frozen_string_literal: true

module CKB
  class AnyoneCanPayTransactionGenerator < TransactionGenerator
    attr_accessor :need_sudt, :sudt_args, :anyone_can_pay_cell_lock_scripts, :is_owner

    def generate(anyone_can_pay_collector:, udt_collector:, capacity_collector:, contexts:, fee_rate: 1)
      transaction.outputs.each_with_index do |output, index|
        if type_script = output.type
          if type_handler = CKB::Config.instance.type_handler(type_script)
            output_data = transaction.outputs_data[index]
            cell_meta = CKB::CellMeta.new(api: api, out_point: nil, output: output, output_data_len: Utils.hex_to_bin(output_data).bytesize, cellbase: false)
            type_handler.generate(cell_meta: cell_meta, tx_generator: self)
          end
        end
      end

      capacity_change_output_index = transaction.outputs.rindex { |output| output.capacity == 0 }
      amount_change_output_index = is_owner ? capacity_change_output_index : transaction.outputs_data.rindex { |output_data| output_data == "0x#{'0' * 32}" }

      handle_anyone_can_pay_cells(anyone_can_pay_collector, contexts, fee_rate)
      handle_sudt_cells(udt_collector, amount_change_output_index, contexts, fee_rate)
      handle_normal_cells(capacity_collector, capacity_change_output_index, contexts, fee_rate)
    end

    def enough_anyone_can_pay_cells?
      cell_metas.map { |cell_meta| cell_meta.output.lock.compute_hash }.sort == anyone_can_pay_cell_lock_scripts.map(&:compute_hash).sort
    end

    def enough_assets?(change_output_index)
      inputs_sudt_amount = cell_metas.select { |cell_meta| !cell_meta.output.type.nil? }.map { |cell_meta| CKB::Utils.sudt_amount!(cell_meta.output_data) }.sum
      outputs_sudt_amount = transaction.outputs_data.map { |output_data| CKB::Utils.sudt_amount!(output_data) }.sum
      change_sudt_amount = inputs_sudt_amount - outputs_sudt_amount
      if change_sudt_amount >= 0
        data = CKB::Utils.generate_sudt_amount(change_sudt_amount)
        transaction.outputs_data[change_output_index] = data
        true
      else
        false
      end
    end

    private

    def handle_normal_cells(capacity_collector, capacity_change_output_index, contexts, fee_rate)
      unless enough_capacity = enough_capacity?(capacity_change_output_index, fee_rate)
        capacity_collector.each do |cell_meta|
          lock_script = cell_meta.output.lock
          type_script = cell_meta.output.type
          next if !is_owner && (type_script || cell_meta.output_data_len > 0)

          lock_handler = CKB::Config.instance.lock_handler(lock_script)
          lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script.compute_hash])
          if type_script
            type_handler = CKB::Config.instance.type_handler(type_script)
            type_handler.generate(cell_meta: cell_meta, tx_generator: self)
          end
          if enough_capacity?(capacity_change_output_index, fee_rate)
            enough_capacity = true
            break
          end
        end
      end
      raise "collected capacity not enough" unless enough_capacity
    end

    def handle_sudt_cells(udt_collector, amount_change_output_index, contexts, fee_rate)
      return unless need_sudt

      unless enough_assets = enough_assets?(amount_change_output_index)
        udt_collector.each do |cell_meta|
          lock_script = cell_meta.output.lock
          type_script = cell_meta.output.type
          if type_script && type_script.code_hash == CKB::Config.instance.sudt_info[:code_hash] && type_script.args == sudt_args
            lock_handler = CKB::Config.instance.lock_handler(lock_script)
            lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script.compute_hash])
            type_handler = CKB::Config.instance.type_handler(type_script)
            type_handler.generate(cell_meta: cell_meta, tx_generator: self)
            if enough_assets?(amount_change_output_index)
              enough_assets = true

              break
            end
          end
        end
        raise "collected assets not enough" unless enough_assets
      end
    end

    def handle_anyone_can_pay_cells(anyone_can_pay_collector, contexts, fee_rate)
      enough_anyone_can_pay_cells = is_owner
      anyone_can_pay_collector.each do |cell_meta|
        lock_script = cell_meta.output.lock
        type_script = cell_meta.output.type
        lock_handler = CKB::Config.instance.lock_handler(lock_script)
        lock_handler.generate(cell_meta: cell_meta, tx_generator: self, context: contexts[lock_script.compute_hash])
        if type_script
          type_handler = CKB::Config.instance.type_handler(type_script)
          type_handler.generate(cell_meta: cell_meta, tx_generator: self)
        end
        if enough_anyone_can_pay_cells?
          enough_anyone_can_pay_cells = true
          unless is_owner
            transaction.outputs.select { |output| output.lock.code_hash == CKB::Config.instance.anyone_can_pay_info[:code_hash] }.each do |output|
              if index = cell_metas.find_index { |inner_cell_meta| inner_cell_meta.output.lock.code_hash == output.lock.code_hash }
                if need_sudt
                  output.capacity = cell_metas[index].output.capacity
                else
                  output.capacity = cell_metas[index].output.capacity + output.capacity
                end
              end
            end


            transaction.outputs.each_with_index do |output, index|
              next if output.lock.code_hash != CKB::Config.instance.anyone_can_pay_info[:code_hash]
              transfer_amount = CKB::Utils.sudt_amount!(transaction.outputs_data[index])
              if index = cell_metas.find_index { |inner_cell_meta| inner_cell_meta.output.lock.code_hash == output.lock.code_hash }
                if need_sudt
                  origin_amount = CKB::Utils.sudt_amount!(cell_metas[index].output_data)
                  transaction.outputs_data[index] = CKB::Utils.generate_sudt_amount(transfer_amount + origin_amount)
                else
                  origin_amount = CKB::Utils.sudt_amount!(cell_metas[index].output_data)
                  transaction.outputs_data[index] = CKB::Utils.generate_sudt_amount(origin_amount)
                end
              end
            end
          end

          break
        end
      end
      raise "collected anyone can pay cell not enough" unless enough_anyone_can_pay_cells
    end
  end
end
