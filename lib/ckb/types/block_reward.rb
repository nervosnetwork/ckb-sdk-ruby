# frozen_string_literal: true

module CKB
  module Types
    class BlockReward
      attr_accessor :total, :primary, :secondary, :tx_fee, :proposal_reward

      # @param total [String] number
      # @param primary [String] number
      # @param secondary [String] number
      # @param tx_fee [String] number
      # @param proposal_reward [String] number
      def initialize(total:, primary:, secondary:, tx_fee:, proposal_reward:)
        @total = total
        @primary = primary
        @secondary = secondary
        @tx_fee = tx_fee
        @proposal_reward = proposal_reward
      end

      def to_h
        {
          total: @total,
          primary: @primary,
          secondary: @secondary,
          tx_fee: @tx_fee,
          proposal_reward: @proposal_reward
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          total: hash[:total],
          primary: hash[:primary],
          secondary: hash[:secondary],
          tx_fee: hash[:tx_fee],
          proposal_reward: hash[:proposal_reward]
        )
      end
    end
  end
end
