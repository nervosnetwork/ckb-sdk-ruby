# frozen_string_literal: true

module CKB
  module Types
    class Epoch
      attr_reader :block_reward, :difficulty, :last_block_hash_in_previous_epoch, :length, :number, :remainder_reward, :start_number

      # @param block_reward [String] number
      # @param difficulty [String] 0x...
      # @param last_block_hash_in_previous_epoch [String] 0x...
      # @param length [String] number
      # @param number [String] number
      # @param remainer_reward [String] number
      # @param start_number [Sring] number
      def initialize(
        block_reward:,
        difficulty:,
        last_block_hash_in_previous_epoch:,
        length:,
        number:,
        remainder_reward:,
        start_number:
      )
        @block_reward = block_reward
        @difficulty = difficulty
        @last_block_hash_in_previous_epoch = last_block_hash_in_previous_epoch
        @length = length
        @number = number
        @remainder_reward = remainder_reward
        @start_number = start_number
      end

      def to_h
        {
          block_reward: @block_reward,
          difficulty: @difficulty,
          last_block_hash_in_previous_epoch: @last_block_hash_in_previous_epoch,
          length: @length,
          number: @number,
          remainder_reward: @remainder_reward,
          start_number: @start_number
        }
      end

      def self.from_h(hash)
        new(
          block_reward: hash[:block_reward],
          difficulty: hash[:difficulty],
          last_block_hash_in_previous_epoch: hash[:last_block_hash_in_previous_epoch],
          length: hash[:length],
          number: hash[:number],
          remainder_reward: hash[:remainder_reward],
          start_number: hash[:start_number]
        )
      end
    end
  end
end
