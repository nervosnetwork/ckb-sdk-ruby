# frozen_string_literal: true

module CKB
  module Types
    class DryRunResult
      attr_reader :cycles

      # @param cycles [String] number
      def initialize(cycles:)
        @cycles = cycles
      end

      def to_h
        {
          cycles: @cycles
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
