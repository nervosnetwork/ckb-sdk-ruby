# frozen_string_literal: true

module CKB
  module Types
    class Alert
      attr_reader :id, :cancel, :priority, :message, :notice_until, :signatures

      # @param id [String]
      # @param cancel [String]
      # @param priority [String]
      # @param message [String]
      # @param notice_until [String]
      # @param signatures [String[]]
      def initialize(id:, cancel:, priority:, message:, notice_until:, signatures:)
        @id = id
        @cancel = cancel
        @priority = priority
        @message = message
        @notice_until = notice_until
        @signatures = signatures
      end

      def to_h
        {
          id: id,
          cancel: cancel,
          priority: priority,
          message: message,
          notice_until: notice_until,
          signatures: signatures
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          id: hash[:id],
          cancel: hash[:cancel],
          priority: hash[:priority],
          message: hash[:message],
          notice_until: hash[:notice_until],
          signatures: hash[:signatures]
        )
      end
    end
  end
end
