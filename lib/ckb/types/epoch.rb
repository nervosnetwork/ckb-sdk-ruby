# frozen_string_literal: true

module CKB
  module Types
    class Epoch
      attr_accessor :difficulty, :length, :number, :start_number

      # @param difficulty [String] 0x...
      # @param length [String] number
      # @param number [String] number
      # @param start_number [Sring] number
      def initialize(
        difficulty:,
        length:,
        number:,
        start_number:
      )
        @difficulty = difficulty
        @length = length
        @number = number
        @start_number = start_number
      end

      def to_h
        {
          difficulty: @difficulty,
          length: @length,
          number: @number,
          start_number: @start_number
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          difficulty: hash[:difficulty],
          length: hash[:length],
          number: hash[:number],
          start_number: hash[:start_number]
        )
      end
    end
  end
end
