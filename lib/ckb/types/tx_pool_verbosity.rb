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
          pending: pending,
          proposed: proposed
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          pending: hash[:pending].map { |k, v| [k, TxVerbosity.from_h(v)] }.to_h,
          proposed: hash[:proposed].map { |k, v| [k, TxVerbosity.from_h(v)] }.to_h
        )
      end
    end
  end
end
