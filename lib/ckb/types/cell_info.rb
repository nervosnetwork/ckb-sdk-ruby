# frozen_string_literal: true

module CKB
  module Types
    class CellInfo
      attr_accessor :output, :data

      # @param output [CKB::Types::Output]
      # @param data [CKB::Types::CellData | nil]
      def initialize(data:, output: nil)
        @output = output
        @data = data
      end

      def to_h
        {
          output: output.to_h,
          data: data.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        output = Output.from_h(hash[:output])
        data = CellData.from_h(hash[:data])

        new(
          output: output,
          data: data
        )
      end
    end
  end
end
