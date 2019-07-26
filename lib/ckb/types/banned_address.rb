# frozen_string_literal: true

module CKB
  module Types
    class BannedAddress
      attr_accessor :address, :ban_until, :ban_reason, :created_at

      # @param address [String]
      # @param ban_until [String] timestamp
      # @param ban_reason [String]
      # @param created_at [String] timestamp
      def initialize(address:, ban_until:, ban_reason:, created_at:)
        @address = address
        @ban_until = ban_until
        @ban_reason = ban_reason
        @created_at = created_at
      end

      def to_h
        {
          address: @address,
          ban_until: @ban_until,
          ban_reason: @ban_reason,
          created_at: @created_at
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          address: hash[:address],
          ban_until: hash[:ban_until],
          ban_reason: hash[:ban_reason],
          created_at: hash[:created_at]
        )
      end
    end
  end
end
