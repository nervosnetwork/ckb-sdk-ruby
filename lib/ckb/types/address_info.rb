# frozen_string_literal: true

module CKB
  module Types
    class AddressInfo
      attr_reader :address, :score

      # @param address [String]
      # @param score [Integer]
      def initialize(address:, score:)
        @address = address
        @score = score
      end

      def to_h
        {
          address: @address,
          score: @score
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
