# frozen_string_literal: true

module CKB
  module Types
    class OutPoint
      attr_reader :block_hash, :cell

      # @param block_hash [String | nil] 0x...
      # @param cell [CKB::Types::OutPointCell | nil]
      def initialize(block_hash: nil, cell: nil)
        @block_hash = block_hash
        @cell = cell
      end

      def to_h
        {
          block_hash: @block_hash,
          cell: @cell&.to_h
        }
      end

      def self.from_h(hash)
        cell = OutPointCell.from_h(hash[:cell]) if hash[:cell]
        new(
          block_hash: hash[:block_hash],
          cell: cell
        )
      end
    end
  end
end
