# frozen_string_literal: true

module CKB
  module Types
    class CellDep
      attr_accessor :out_point, :is_group

      # @param out_point [CKB::Types::CellOutPoint | nil]
      # @param is_group [Boolean]
      def initialize(out_point: nil, is_group:)
        @out_point = out_point
        @is_group = is_group
      end

      def to_h
        {
          out_point: out_point.to_h,
          is_group: is_group,
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        out_point = CellOutPoint.from_h(hash[:out_point])
        new(
          out_point: out_point,
          is_group: hash[:is_group]
        )
      end
    end
  end
end
