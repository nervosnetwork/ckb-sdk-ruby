# frozen_string_literal: true

module CKB
  module Types
    class Input
      attr_reader :args, :previous_output, :since

      # @param args [String[]] ["0x..."]
      # @param previous_output [CKB::Types::OutPoint]
      # @param since [String | Integer]
      def initialize(args:, previous_output:, since: "0")
        @args = args
        @previous_output = previous_output
        @since = since.to_s
      end

      def to_h
        {
          args: @args,
          previous_output: @previous_output.to_h,
          since: since.to_s
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          args: hash[:args],
          previous_output: OutPoint.from_h(hash[:previous_output]),
          since: hash[:since]
        )
      end
    end
  end
end
