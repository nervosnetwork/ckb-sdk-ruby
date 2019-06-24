# frozen_string_literal: true

module CKB
  module Types
    class Epoch
      attr_reader :epoch_reward, :difficulty, :length, :number, :start_number

      # @param epoch_reward [String] number
      # @param difficulty [String] 0x...
      # @param length [String] number
      # @param number [String] number
      # @param start_number [Sring] number
      def initialize(
        epoch_reward:,
        difficulty:,
        length:,
        number:,
        start_number:
      )
        @epoch_reward = epoch_reward
        @difficulty = difficulty
        @length = length
        @number = number
        @start_number = start_number
      end

      def to_h
        {
          epoch_reward: @epoch_reward,
          difficulty: @difficulty,
          length: @length,
          number: @number,
          start_number: @start_number
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          epoch_reward: hash[:epoch_reward],
          difficulty: hash[:difficulty],
          length: hash[:length],
          number: hash[:number],
          start_number: hash[:start_number]
        )
      end
    end
  end
end
