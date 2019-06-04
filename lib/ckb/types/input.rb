# frozen_string_literal: true

module CKB
  module Types
    class Input
      attr_reader :block_number, :previous_output, :since

      # @param previous_output [CKB::Types::OutPoint]
      # @param since [String]
      # @param block_number [String]
      def initialize(previous_output:, since: "0", block_number: "0")
        @previous_output = previous_output
        @since = since.to_s
        @block_number = block_number.to_s
      end

      def to_h
        {
          block_number: block_number,
          previous_output: @previous_output.to_h,
          since: since
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          block_number: hash[:block_number],
          previous_output: OutPoint.from_h(hash[:previous_output]),
          since: hash[:since]
        )
      end
    end
  end
end
