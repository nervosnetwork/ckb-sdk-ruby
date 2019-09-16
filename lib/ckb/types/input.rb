# frozen_string_literal: true

module CKB
  module Types
    class Input
      attr_accessor :previous_output, :since

      # @param previous_output [CKB::Types::OutPoint]
      # @param since [String | Integer] integer or hex number
      def initialize(previous_output:, since: 0)
        @previous_output = previous_output
        @since = Utils.to_int(since)
      end

      def to_h
        {
          previous_output: @previous_output.to_h,
          since: Utils.to_hex(@since)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          previous_output: OutPoint.from_h(hash[:previous_output]),
          since: hash[:since]
        )
      end
    end
  end
end
