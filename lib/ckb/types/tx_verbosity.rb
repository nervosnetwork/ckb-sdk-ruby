# frozen_string_literal: true

module CKB
  module Types
    class TxVerbosity
      attr_accessor :cycles, :size, :fee, :ancestors_size, :ancestors_cycles, :ancestors_count

      # @param cycles  [String | Integer]
      # @param size [String | Integer]
      # @param fee [String | Integer]
      # @param ancestors_size [String | Integer]
      # @param ancestors_cycles [String | Integer]
      # @param ancestors_count [String | Integer]
      # @param
      def initialize(cycles:, size:, fee:, ancestors_size:, ancestors_cycles:, ancestors_count:)
        @cycles = Utils.to_int(cycles)
        @size = Utils.to_int(size)
        @fee = Utils.to_int(fee)
        @ancestors_size = Utils.to_int(ancestors_size)
        @ancestors_cycles = Utils.to_int(ancestors_cycles)
        @ancestors_count = Utils.to_int(ancestors_count)
      end

      def to_h
        {
          cycles: Utils.to_hex(cycles),
          size: Utils.to_hex(size),
          fee: Utils.to_hex(fee),
          ancestors_size: Utils.to_hex(ancestors_size),
          ancestors_cycles: Utils.to_hex(ancestors_cycles),
          ancestors_count: Utils.to_hex(ancestors_count)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          cycles: hash[:cycles],
          size: hash[:size],
          fee: hash[:fee],
          ancestors_size: hash[:ancestors_size],
          ancestors_cycles: hash[:ancestors_cycles],
          ancestors_count: hash[:ancestors_count]
        )
      end
    end
  end
end
