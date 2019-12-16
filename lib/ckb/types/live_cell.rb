# frozen_string_literal: true

module CKB
  module Types
    class LiveCell
      attr_accessor :cell_output, :created_by, :cellbase
      attr_reader :output_data_len

      # @param cell_output [Types::Output]
      # @param created_by [Types::TransactionPoint]
      # @param cellbase [Boolean]
      # @param output_data_len [Integer]
      def initialize(cell_output:, created_by:, cellbase:, output_data_len:)
        @cell_output = cell_output
        @created_by = created_by
        @cellbase = cellbase

        self.output_data_len = output_data_len
      end

      def output_data_len=(value)
        @output_data_len = Utils.to_int(value)
      end

      def to_h
        {
          cell_output: @cell_output.to_h,
          created_by: @created_by.to_h,
          cellbase: @cellbase,
          output_data_len: Utils.to_hex(@output_data_len)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          cell_output: Output.from_h(hash[:cell_output]),
          created_by: TransactionPoint.from_h(hash[:created_by]),
          cellbase: hash[:cellbase],
          output_data_len: hash[:output_data_len]
        )
      end
    end
  end
end
