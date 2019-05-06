# frozen_string_literal: true

module CKB
  module Types
    class TxStatus
      attr_reader :status, :block_hash

      # @param status [String] proposed", "pending", "committed"
      # @param block_hash [String | nil] "0x..."
      def initialize(status:, block_hash:)
        @status = status
        @block_hash = block_hash
      end

      def to_h
        {
          status: @status,
          block_hash: @block_hash
        }
      end

      def self.from_h(hash)
        new(
          status: hash[:status],
          block_hash: hash[:block_hash]
        )
      end
    end
  end
end
