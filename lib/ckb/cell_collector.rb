# frozen_string_literal: true

module CKB
  class CellCollector
    attr_reader :indexer_api, :skip_data_and_type

    # @param indexer_api [CKB::Indexer::API]
    # @param skip_data_and_type [Boolean]
    def initialize(indexer_api, skip_data_and_type: true)
      @indexer_api = indexer_api
      @skip_data_and_type = skip_data_and_type
    end

    # @param search_key [CKB::Indexer::Types::SearchKey]
    # @param order [String]
    # @param limit [Integer]
    # @param cursor [string]
    def get_unspent_cells(search_key:, order: "asc", limit: CKB::Indexer::API::DEFAULT_LIMIT, cursor: nil, need_capacities: nil)
      results = []
      total_capacities = 0
      loop do
        liveCells = indexer_api.get_cells(search_key: search_key, order: order, limit: limit, after_cursor: cursor)
        liveCells.objects.each do |cell|
          next if skip_data_and_type && (cell.output_data != "0x" || !cell.output.type.nil?)

          results << cell
          total_capacities += cell.output.capacity
          break if need_capacities && total_capacities >= need_capacities
        end

        if liveCells.objects.size < limit || liveCells.last_cursor == "" || need_capacities && total_capacities >= need_capacities
          break
        end

        cursor = liveCells.last_cursor
      end
      {
        outputs: results,
        total_capacities: total_capacities
      }
    end

    # @param search_keys [CKB::Indexer::Types::SearchKey[]]
    # @param order [String]
    # @param limit [Integer]
    # @param cursor [string]
    def get_unspent_cells_by_search_keys(search_keys:, order: "asc", limit: CKB::Indexer::API::DEFAULT_LIMIT, cursor: nil, need_capacities: nil)
      total_capacities = 0
      outputs = []
      search_keys.map do |search_key|
        result = get_unspent_cells(
          search_key: search_key,
          order: order,
          limit: limit,
          cursor: cursor,
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

    # @param search_keys [CKB::Indexer::Types::SearchKey[]]
    # @param capacity [Integer]
    # @param min_change_capacity [Integer]
    # @param fee [Integer]
    def gather_inputs(search_keys, capacity, min_change_capacity, fee, order: "asc", limit: CKB::Indexer::API::DEFAULT_LIMIT, cursor: nil)
      total_capacities = capacity + fee
      input_capacities = 0
      inputs = []
      witnesses = []
      get_unspent_cells_by_search_keys(search_keys: search_keys, order: order, limit: limit, cursor: cursor, need_capacities: total_capacities + min_change_capacity)[:outputs].each do |cell|
        input = Types::Input.new(
          previous_output: cell.out_point,
          since: 0
        )
        inputs << input
        witnesses << CKB::Types::Witness.new
        input_capacities += cell.output.capacity.to_i

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
