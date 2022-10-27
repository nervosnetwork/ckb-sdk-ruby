# frozen_string_literal: true

module CKB
  module Types
    class TxStatus
      attr_accessor :status, :block_hash

      # @param status [String] "proposed", "pending", "committed"
      # @param block_hash [String | nil] "0x..."
      # @param reason [String | nil] '{"type":"Resolveg","description":"Resolve failed Dead(OutPoint(0x...))"}'
      def initialize(status:, block_hash:, reason:)
        @status = status
        @block_hash = block_hash
        @reason = reason
      end

      def to_h
        {
          status: @status,
          block_hash: @block_hash,
          reason: @reason
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          status: hash[:status],
          block_hash: hash[:block_hash],
          reason: hash[:reason]
        )
      end
    end
  end
end
