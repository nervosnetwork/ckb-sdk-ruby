# frozen_string_literal: true

module CKB
  module Indexer
    module Types
      class Transaction
        attr_reader :block_number, :tx_hash, :tx_index, :io_index, :io_type

        # @param block_number [String | Integer] integer or hex number
        # @param tx_hash [String]
        # @param tx_index [String | Integer] integer or hex number
        # @param io_index [String | Integer] integer or hex number
        # @param io_type [String] "input" or "output"
        def initialize(block_number:, tx_hash:, tx_index:, io_index:, io_type:)
          @block_number = Utils.to_int(block_number)
          @tx_hash = tx_hash
          @tx_index = Utils.to_int(tx_index)
          @io_index = Utils.to_int(io_index)
          @io_type = io_type
        end

        def self.from_h(hash)
          return if hash.nil?

          new(
            block_number: hash[:block_number],
            tx_hash: hash[:tx_hash],
            tx_index: hash[:tx_index],
            io_index: hash[:io_index],
            io_type: hash[:io_type],
          )
        end
      end
    end
  end
end
