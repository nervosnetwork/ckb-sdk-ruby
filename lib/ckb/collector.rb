# frozen_string_literal: true

module CKB
  MAX_PAGINATES_PER = 50
  MAX_PAGE_SIZE = 100

  class Collector
    attr_reader :api
    def initialize(api)
      @api = api
    end

    def default_scanner(lock_hashes:, from_block_number: 0)
      tip_block_number = api.get_tip_block_number
      lock_hash_index = 0
      from = from_block_number
      cell_meta_index = 0
      cell_metas = []
      Enumerator.new do |result|
        while cell_meta_index < cell_metas.size || lock_hash_index < lock_hashes.size
          if cell_meta_index < cell_metas.size
            result << cell_metas[cell_meta_index]
            cell_meta_index +=1
          else
            cell_meta_index = 0
            cell_metas = api.get_cells_by_lock_hash(lock_hashes[lock_hash_index], from, from + MAX_PAGE_SIZE).map do |cell|
              output_data_len = cell.output_data_len
              cellbase = cell.cellbase
              CKB::CellMeta.new(api: api, out_point: cell.out_point, output: CKB::Types::Output.new(capacity: cell.capacity, lock: cell.lock, type: cell.type), output_data_len: output_data_len, cellbase: cellbase)
            end
            from += MAX_PAGE_SIZE + 1
            if from > tip_block_number
              from = 0
              lock_hash_index += 1
            end
          end
        end
      end
    end

    def default_indexer(search_keys:, order: "asc")
      search_key_index = 0
      cursor = nil
      cell_meta_index = 0
      cell_metas = []

      Enumerator.new do |result|
        while cell_meta_index < cell_metas.size || search_key_index < search_keys.size
          if cell_meta_index < cell_metas.size
            result << cell_metas[cell_meta_index]
            cell_meta_index += 1
          else
            cell_meta_index = 0
            live_cells = api.get_cells(search_key: search_keys[search_key_index], order: order, limit: MAX_PAGINATES_PER, after_cursor: cursor)
            cell_metas = live_cells.objects.map do |live_cell|
              CKB::CellMeta.new(api: nil, out_point: live_cell.out_point, output: live_cell.output, output_data_len: Utils.hex_to_bin(live_cell.output_data).bytesize, cellbase: nil)
            end
            cursor = live_cells.last_cursor
            if cell_metas.empty?
              cursor = nil
              search_key_index += 1
            end
          end
        end
      end
    end
  end
end
