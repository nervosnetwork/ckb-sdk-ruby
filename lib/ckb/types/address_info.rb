# frozen_string_literal: true

module CKB
  module Types
    class AddressInfo
      attr_accessor :address, :score

      # @param address [String]
      # @param score [String | Integer] integer or hex number
      def initialize(address:, score:)
        @address = address
        @score = Utils.to_int(score)
      end

      def to_h
        {
          address: @address,
          score: Utils.to_hex(@score)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          address: hash[:address],
          score: hash[:score]
        )
      end
    end
  end
end
