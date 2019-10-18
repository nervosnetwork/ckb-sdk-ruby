# frozen_string_literal: true
require "bigdecimal"

module CKB
  class CellCollectorByFeeRate
    attr_reader :api, :skip_data_and_type, :hash_type

    # @param api [CKB::API]
    def initialize(api, skip_data_and_type: true, hash_type: "type")
      @api = api
      @skip_data_and_type = skip_data_and_type
      @hash_type = hash_type
    end

    # @param lock_hash [String]
    # @param fee_rate [Integer] shannons per KB
    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    #
    # @return [Hash]
    def get_unspent_cells(lock_hash, fee_rate, need_capacities: nil)
      to = api.get_tip_block_number.to_i
      results = []
      total_capacities = 0
      need_fee = 0
      current_from = 0
      while current_from <= to
        current_to = [current_from + 100, to].min
        cells = api.get_cells_by_lock_hash(lock_hash, current_from, current_to)
        if skip_data_and_type
          cells.each do |cell|
            live_cell = api.get_live_cell(cell.out_point, true)
            output = live_cell.cell.output
            output_data = live_cell.cell.data.content
            if (output_data.nil? || output_data == "0x") && output.type.nil?
              results << cell
              total_capacities += cell.capacity
              need_fee += every_input_fee(fee_rate)
              break if need_capacities && total_capacities - need_fee >= need_capacities
            end
          end
          break if need_capacities && total_capacities - need_fee >= need_capacities
        else
          results.concat(cells)
          total_capacities += cells.map(&:capacity).reduce(:+)
          need_fee = result.size * every_input_fee(fee_rate)
          break if need_capacities && total_capacities - need_fee >= need_capacities
        end
        current_from = current_to + 1
      end
      {
        outputs: results,
        total_capacities: total_capacities,
        need_fee: need_fee
      }
    end

    def every_input_fee(fee_rate)
      (TransactionSize.every_input + TransactionSize.every_secp_witness) * fee_rate / BigDecimal(1000)
    end

    # @param lock_hashes [String[]]
    # @param fee_rate [Integer] shannons per KB
    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    #
    # @return [Hash]
    def get_unspent_cells_by_lock_hashes(lock_hashes, fee_rate, need_capacities: nil)
      total_capacities = 0
      need_fee = 0
      outputs = []
      lock_hashes.map do |lock_hash|
        result = get_unspent_cells(
          lock_hash,
          fee_rate,
          need_capacities: need_capacities && need_capacities - total_capacities
        )
        outputs += result[:outputs]
        total_capacities += result[:total_capacities]
        need_fee += result[:need_fee]
        break if need_capacities && total_capacities - need_fee >= need_capacities
      end

      {
        outputs: outputs,
        total_capacities: total_capacities,
        need_fee: need_fee,
      }
    end

    # @param lock_hashes [String[]]
    # @param capacity [Integer]
    # @param min_capacity [Integer]
    # @param min_change_capacity [Integer]
    # @param fee_rate [Integer] shannons per KB
    def gather_inputs(lock_hashes, capacity, min_capacity, min_change_capacity, fee_rate)
      raise "capacity cannot be less than #{min_capacity}" if capacity < min_capacity

      total_capacities = capacity
      input_capacities = 0
      inputs = []
      witnesses = []
      need_fee = 0
      get_unspent_cells_by_lock_hashes(lock_hashes, fee_rate, need_capacities: total_capacities)[:outputs].each do |cell|
        input = Types::Input.new(
          previous_output: cell.out_point,
          since: 0
        )
        inputs << input
        witnesses << "0x"
        input_capacities += cell.capacity.to_i
        need_fee += every_input_fee(fee_rate)

        diff = input_capacities - total_capacities - need_fee
        break if diff >= min_change_capacity || diff.zero?
      end

      raise "Capacity not enough!" if input_capacities < total_capacities

      OpenStruct.new(
        inputs: inputs,
        capacities: input_capacities,
        witnesses: witnesses,
        need_fee: need_fee
      )
    end
  end
end
