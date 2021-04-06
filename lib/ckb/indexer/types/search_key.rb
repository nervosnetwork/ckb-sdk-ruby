# frozen_string_literal: true

module CKB
  module Indexer
    module Types
      class SearchKey
        attr_accessor :script, :script_type, :args_len, :filter

        def initialize(script, script_type, args_len: nil, filter: nil)
          raise ArgumentError, "script type must be CKB::Types::Script" unless script.is_a?(CKB::Types::Script)
          raise ArgumentError, "invalid script_type: #{script_type}" unless %w[lock type].include?(script_type)

          if filter && !filter.is_a?(CKB::Indexer::Types::SearchKeyFilter)
            raise ArgumentError,
                  "filter type must be CKB::Indexer::Types::SearchKeyFilter"
          end

          @script = script
          @script_type = script_type
          @args_len = args_len
          @filter = filter
        end

        def to_h
          hash = {
            script: script.to_h,
            script_type: script_type
          }
          hash[:args_len] = Utils.to_hex(args_len) if args_len
          hash[:filter] = filter.to_h if filter

          hash
        end
      end
    end
  end
end
