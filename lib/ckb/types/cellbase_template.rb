# frozen_string_literal: true

module CKB
  module Types
    class CellbaseTemplate
      attr_accessor :hash, :cycles, :data

      # @param hash [String] 0x..
      # @param cycles [String | Integer] integer or hex number
      # @param data [CKB::Type::Transaction]
      def initialize(hash:, cycles:, data:)
        @hash = hash
        @cycles = Utils.to_int(cycles)
        @data = data
      end

      def to_h
        {
          hash: hash,
          cycles: Utils.to_hex(cycles),
          data: data.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          cycles: hash[:cycles],
          data: Transaction.from_h(hash[:data]),
        )
      end
    end
  end
end

