# frozen_string_literal: true

module CKB
  module Types
    class LiveCell
      attr_reader :cell_output, :created_by

      # @param cell_output [Types::Output]
      # @param created_by [Types::TransactionPoint]
      def initialize(cell_output:, created_by:)
        @cell_output = cell_output
        @created_by = created_by
      end

      def to_h
        {
          cell_output: @cell_output.to_h,
          created_by: @created_by.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          cell_output: Output.from_h(hash[:cell_output]),
          created_by: TransactionPoint.from_h(hash[:created_by])
        )
      end
    end
  end
end