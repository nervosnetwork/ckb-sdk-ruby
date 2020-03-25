# frozen_string_literal: true

module CKB
  class Collector
    attr_reader :api
    def initialize(api)
      @api = api
    end

    def default_scanner(lock_hashes:, from_block_numer: 0)
      tip_block_number = api.get_tip_block_number
      lock_hash_index = 0
      from = from_block_numer
      cell_meta_index = 0
      cell_metas = []
      Enumerator.new do |result|
        while cell_meta_index < cell_metas.size || lock_hash_index < lock_hashes.size
          if cell_meta_index < cell_metas.size
            result << cell_metas[cell_meta_index]
            cell_meta_index +=1
          else
            cell_meta_index = 0
            binding.pry
            cell_metas = api.get_cells_by_lock_hash(lock_hashes[lock_hash_index], from, from + 100).map do |cell|
              output_data_len = cell.output_data_len
              cellbase = cell.cellbase
              CKB::CellMeta.new(api: api, out_point: cell.out_point, output: CKB::Types::Output.new(capacity: cell.capacity, lock: cell.lock, type: cell.type), output_data_len: output_data_len, cellbase: cellbase)
            end

            from += 100
            if from > tip_block_number
              from = 0
              lock_hash_index += 1
            end
          end
        end
      end
    end

    def default_indexer(lock_hashes)
      lock_hash_index = 0
      page = 0
      cell_meta_index = 0
      cell_metas = []

      Enumerator.new do |result|
        while cell_meta_index < cell_metas.size || lock_hash_index < lock_hashes.size
          if cell_meta_index < cell_metas.size
            result << cell_metas[cell_meta_index]
            cell_meta_index += 1
          else
            cell_metas = api.get_live_cells_by_lock_hash(lock_hashes[lock_hash_index]).map do |cell_meta|
              output_data_len = cell.output_data_len
              cellbase = cell.cellbase
              CKB::CellMeta.new(api: api, out_point: cell.out_point, output: CKB::Types::Output.new(capacity: cell.capacity, lock: cell.lock, type: cell.type), output_data_len: output_data_len, cellbase: cellbase)
            end

            page += 1
            if cell_metas.empty?
              page = 0
              lock_hash_index += 1
            end
          end
        end
      end
    end
  end
end
