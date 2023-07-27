# frozen_string_literal: true

module CKB
  module Types
    class FeeRateStatistics
      attr_accessor :mean, :median

      # @param mean [String]
      # @param median [String]
      def initialize(mean:, median:)
        @mean = mean
        @median = median
      end

      def to_h
        {
          mean: mean,
          median: median
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          mean: hash[:mean],
          median: hash[:median]
        )
      end
    end
  end
end
