# frozen_string_literal: true

module CKB
  module Indexer
    module Types
      class SearchKey
        attr_accessor :script, :script_type, :filter, :with_data

        def initialize(script, script_type, filter: nil, with_data: true)
          raise ArgumentError, "script type must be CKB::Types::Script" unless script.is_a?(CKB::Types::Script)
          raise ArgumentError, "invalid script_type: #{script_type}" unless %w[lock type].include?(script_type)

          if filter && !filter.is_a?(CKB::Indexer::Types::SearchKeyFilter)
            raise ArgumentError,
                  "filter type must be CKB::Indexer::Types::SearchKeyFilter"
          end

          @script = script
          @script_type = script_type
          @filter = filter
          @with_data = with_data
        end

        def to_h
          hash = {
            script: script.to_h,
            script_type: script_type
          }
          hash[:with_data] = with_data unless with_data.nil?
          hash[:filter] = filter.to_h if filter

          hash
        end
      end
    end
  end
end
