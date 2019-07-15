# frozen_string_literal: true

module CKB
  module Types
    class LockHashIndexState
      attr_accessor :lock_hash, :block_number, :block_hash

      # @param lock_hash [String]
      # @param block_number [String] number
      # @param block_hash [String]
      def initialize(lock_hash:, block_number:, block_hash:)
        @lock_hash = lock_hash
        @block_number = block_number.to_s
        @block_hash = block_hash
      end

      def to_h
        {
          lock_hash: @lock_hash,
          block_number: @block_number,
          block_hash: @block_hash
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          lock_hash: hash[:lock_hash],
          block_number: hash[:block_number],
          block_hash: hash[:block_hash]
        )
      end
    end
  end
end