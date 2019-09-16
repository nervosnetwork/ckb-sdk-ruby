# frozen_string_literal: true

module CKB
  module Types
    class OutPoint
      attr_accessor :tx_hash, :index

      # @param tx_hash [String] 0x...
      # @param index [String | Integer] integer or hex number
      def initialize(tx_hash:, index:)
        @tx_hash = tx_hash
        @index = Utils.to_int(index)
      end

      def to_h
        {
          tx_hash: tx_hash,
          index: Utils.to_hex(index)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          tx_hash: hash[:tx_hash],
          index: hash[:index]
        )
      end
    end
  end
end
