# frozen_string_literal: true

module CKB
  module Indexer
    module Types
      class SearchKeyFilter
        attr_accessor :script, :script_len_range, :output_data_len_range, :output_capacity_range, :block_range

        def initialize(script: nil, script_len_range: nil, output_data_len_range: nil, output_capacity_range: nil, block_range: nil)
          raise ArgumentError, "script type must be CKB::Types::Script" if script && !script.is_a?(CKB::Types::Script)
          if output_data_len_range && !output_data_len_range.is_a?(Array)
            raise ArgumentError, "output_data_len_range type must be Array"
          end
          if output_capacity_range && !output_capacity_range.is_a?(Array)
            raise ArgumentError, "output_capacity_range type must be Array"
          end
          raise ArgumentError, "block_range type must be Array" if block_range && !block_range.is_a?(Array)

          @script = script
          @script_len_range = script_len_range
          @output_data_len_range = output_data_len_range
          @output_capacity_range = output_capacity_range
          @block_range = block_range
        end

        def to_h
          hash = {}
          hash[:script] = script.to_h if script
          hash[:script_len_range] = script_len_range.map { |r| Utils.to_hex(r) } if script_len_range
          hash[:output_data_len_range] = output_data_len_range.map { |r| Utils.to_hex(r) } if output_data_len_range
          hash[:output_capacity_range] = output_capacity_range.map { |r| Utils.to_hex(r) } if output_capacity_range
          hash[:block_range] = block_range.map { |r| Utils.to_hex(r) } if block_range

          hash
        end
      end
    end
  end
end
