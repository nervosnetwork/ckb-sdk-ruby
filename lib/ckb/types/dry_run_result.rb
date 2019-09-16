# frozen_string_literal: true

module CKB
  module Types
    class DryRunResult
      attr_accessor :cycles

      # @param cycles [String | Integer] integer or hex number
      def initialize(cycles:)
        @cycles = Utils.to_int(cycles)
      end

      def to_h
        {
          cycles: Utils.to_hex(@cycles)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          cycles: hash[:cycles]
        )
      end
    end
  end
end
