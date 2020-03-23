# frozen_string_literal: true

module CKB
  module Types
    class BlockIssuance
      attr_accessor :primary, :secondary

      # @param primary [String | Integer]
      # @param secondary [String | Integer]
      def initialize(
        primary:,
        secondary:
      )
        @primary = Utils.to_int(primary)
        @secondary = Utils.to_int(secondary)
      end

      def to_h
        {
          primary: Utils.to_hex(primary),
          secondary: Utils.to_hex(secondary)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
         primary: hash[:primary],
         secondary: hash[:secondary]
        )
      end
    end
  end
end
