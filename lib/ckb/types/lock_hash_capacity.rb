# frozen_string_literal: true

module CKB
  module Types
    class LockHashCapacity
      attr_accessor :capacity, :cells_count, :block_number

      # @param capacity [String | Integer] integer or hex number
      # @param cells_count [String | Integer] integer or hex number
      # @param block_number [String | Integer] integer or hex number
      def initialize(capacity:, cells_count:, block_number:)
        @capacity = Utils.to_int(capacity)
        @cells_count = Utils.to_int(cells_count)
        @block_number = Utils.to_int(block_number)
      end

      def to_h
        {
          capacity: Utils.to_hex(@capacity),
          cells_count: Utils.to_hex(@cells_count),
          block_number: Utils.to_hex(@block_number)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          capacity: hash[:capacity],
          cells_count: hash[:cells_count],
          block_number: hash[:block_number]
        )
      end
    end
  end
end
