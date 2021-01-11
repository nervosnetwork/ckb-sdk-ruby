module CKB
  module Types
    class TxPoolIds
      attr_accessor :pending, :proposed

      # @param pending [String]
      # @param proposed [String]
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
          pending: hash[:pending],
          proposed: hash[:proposed]
        )
      end
    end
  end
end
