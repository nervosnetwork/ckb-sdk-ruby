# frozen_string_literal: true

module CKB
  module Types
    class TxPoolVerbosity
      attr_accessor :pending, :proposed

      # @param pending [Hash]
      # @param proposed [Hash]
      def initialize(pending:, proposed:)
        @pending = pending
        @proposed = proposed
      end

      def to_h
        {
          pending: pending.transform_values { |v| v.to_h }.to_h,
          proposed: proposed.transform_values { |v| v.to_h }.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          pending: hash[:pending].transform_values { |v| TxVerbosity.from_h(v) }.to_h,
          proposed: hash[:proposed].transform_values { |v| TxVerbosity.from_h(v) }.to_h
        )
      end
    end
  end
end
