# frozen_string_literal: true

module CKB
  module Types
    class MinerReward
      attr_accessor :primary, :secondary, :committed, :proposal

      # @param primary [String | Integer]
      # @param secondary [String | Integer]
      # @param committed [String | Integer]
      # @param proposal [String | Integer]
      def initialize(
        primary:,
        secondary:,
        committed:,
        proposal:
      )
        @primary = Utils.to_int(primary)
        @secondary = Utils.to_int(secondary)
        @committed = Utils.to_int(committed)
        @proposal = Utils.to_int(proposal)
      end

      def to_h
        {
          primary: Utils.to_hex(primary),
          secondary: Utils.to_hex(secondary),
          committed: Utils.to_hex(committed),
          proposal: Utils.to_hex(proposal)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          primary: hash[:primary],
          secondary: hash[:secondary],
          committed: hash[:committed],
          proposal: hash[:proposal]
        )
      end
    end
  end
end
