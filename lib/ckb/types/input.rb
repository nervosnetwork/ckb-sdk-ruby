# frozen_string_literal: true

module CKB
  module Types
    class Input
      attr_accessor :previous_output, :since

      # @param previous_output [CKB::Types::OutPoint]
      # @param since [String]
      def initialize(previous_output:, since: "0")
        @previous_output = previous_output
        @since = since.to_s
      end

      def to_h
        {
          previous_output: @previous_output.to_h,
          since: since
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
