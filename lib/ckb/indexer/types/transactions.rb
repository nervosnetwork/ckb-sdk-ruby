# frozen_string_literal: true

module CKB
  module Indexer
    module Types
      class Transactions
        attr_reader :last_cursor, :objects

        # @param last_cursor [String]
        # @param objects [CKB::Types::Transaction[]]
        def initialize(last_cursor:, objects:)
          @last_cursor = last_cursor
          @objects = objects
        end

        def self.from_h(hash)
          return if hash.nil?

          new(
            last_cursor: hash[:last_cursor],
            objects: hash[:objects].map { |object| CKB::Indexer::Types::Transaction.from_h(object) }
          )
        end
      end
    end
  end
end
