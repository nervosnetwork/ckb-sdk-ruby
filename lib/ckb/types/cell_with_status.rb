# frozen_string_literal: true

module CKB
  module Types
    class CellWithStatus
      attr_accessor :cell, :status

      # @param cell [CKB::Types::CellInfo | nil]
      # @param status [String]
      def initialize(cell:, status:)
        @cell = cell
        @status = status
      end

      def to_h
        {
          cell: @cell.to_h,
          status: @status
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          cell: CellInfo.from_h(hash[:cell]),
          status: hash[:status]
        )
      end
    end
  end
end
