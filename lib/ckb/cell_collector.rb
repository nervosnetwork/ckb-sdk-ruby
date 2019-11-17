# frozen_string_literal: true

module CKB
  class CellCollector
    attr_reader :api, :skip_data_and_type, :hash_type

    # @param api [CKB::API]
    def initialize(api, skip_data_and_type: true, hash_type: "type")
      @api = api
      @skip_data_and_type = skip_data_and_type
      @hash_type = hash_type
    end

    # @param lock_hash [String]
    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    #
    # @return [Hash]
    def get_unspent_cells(lock_hash, need_capacities: nil)
      to = api.get_tip_block_number.to_i
      results = []
      total_capacities = 0
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
              break if need_capacities && total_capacities >= need_capacities
            end
          end
          break if need_capacities && total_capacities >= need_capacities
        else
          results.concat(cells)
          total_capacities += cells.map(&:capacity).reduce(0, :+)
          break if need_capacities && total_capacities >= need_capacities
        end
        current_from = current_to + 1
      end
      {
        outputs: results,
        total_capacities: total_capacities
      }
    end

    # @param lock_hashes [String[]]
    # @param need_capacities [Integer | nil] capacity in shannon, nil means collect all
    #
    # @return [Hash]
    def get_unspent_cells_by_lock_hashes(lock_hashes, need_capacities: nil)
      total_capacities = 0
      outputs = []
      lock_hashes.map do |lock_hash|
        result = get_unspent_cells(
          lock_hash,
          need_capacities: need_capacities && need_capacities - total_capacities
        )
        outputs += result[:outputs]
        total_capacities += result[:total_capacities]
        break if need_capacities && total_capacities >= need_capacities
      end

      {
        outputs: outputs,
        total_capacities: total_capacities
      }
    end

    # @param lock_hashes [String[]]
    # @param capacity [Integer]
    # @param min_change_capacity [Integer]
    # @param fee [Integer]
    def gather_inputs(lock_hashes, capacity, min_change_capacity, fee)
      total_capacities = capacity + fee
      input_capacities = 0
      inputs = []
      witnesses = []
      get_unspent_cells_by_lock_hashes(lock_hashes, need_capacities: total_capacities + min_change_capacity)[:outputs].each do |cell|
        input = Types::Input.new(
          previous_output: cell.out_point,
          since: 0
        )
        inputs << input
        witnesses << CKB::Types::Witness.new
        input_capacities += cell.capacity.to_i

        diff = input_capacities - total_capacities
        break if diff >= min_change_capacity || diff.zero?
      end
      raise "Capacity not enough!" if input_capacities < total_capacities

      witnesses[0].lock = "0x#{'0' * 130}"

      OpenStruct.new(
        inputs: inputs,
        capacities: input_capacities,
        witnesses: witnesses
      )
    end
  end
end
