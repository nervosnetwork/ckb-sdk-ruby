# frozen_string_literal: true

module CKB
  module Types
    class AlertMessage
      attr_accessor :id, :priority, :notice_until, :message

      # @param id [String | Integer] integer or hex number
      # @param priority [String | Integer] integer or hex number
      # @param notice_until [String] timestamp
      # @param message [String]
      def initialize(id:, priority:, notice_until:, message:)
        @id = Utils.to_int(id)
        @priority = Utils.to_int(priority)
        @notice_until = Utils.to_int(notice_until)
        @message = message
      end

      def to_h
        {
          id: Utils.to_hex(@id),
          priority: Utils.to_hex(@priority),
          notice_until: Utils.to_hex(@notice_until),
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