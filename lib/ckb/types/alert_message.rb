# frozen_string_literal: true

module CKB
  module Types
    class AlertMessage
      attr_reader :id, :priority, :notice_until, :message

      # @param id [String]
      # @param priority [String]
      # @param notice_until [String]
      # @param message [String]
      def initialize(id:, priority:, notice_until:, message:)
        @id = id
        @priority = priority
        @notice_until = notice_until
        @message = message
      end

      def to_h
        {
          id: @id,
          priority: @priority,
          notice_until: @notice_until,
          message: @message
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          id: hash[:id],
          priority: hash[:priority],
          notice_until: hash[:notice_until],
          message: hash[:message]
        )
      end
    end
  end
end