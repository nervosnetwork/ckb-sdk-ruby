# frozen_string_literal: true

module CKB
  module Types
    class EstimateResult
      attr_accessor :fee_rate

      # @param fee_rate [String | Integer] integer or hex number
      def initialize(fee_rate:)
        @fee_rate = Utils.to_int(fee_rate)
      end

      def to_h
        {
          fee_rate: Utils.to_hex(@fee_rate)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          fee_rate: hash[:fee_rate]
        )
      end
    end
  end
end
