# frozen_string_literal: true

module CKB
  module Types
    class CellDep
      attr_accessor :out_point, :dep_type

      # @param out_point [CKB::Types::OutPoint | nil]
      # @param dep_type [String]
      def initialize(out_point: nil, dep_type: "code")
        @out_point = out_point
        @dep_type = dep_type
      end

      def to_h
        {
          out_point: out_point.to_h,
          dep_type: dep_type
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        out_point = OutPoint.from_h(hash[:out_point])
        new(
          out_point: out_point,
          dep_type: hash[:dep_type]
        )
      end
    end
  end
end
