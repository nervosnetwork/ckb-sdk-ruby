# frozen_string_literal: true

module CKB
  module Types
    class BlockReward
      attr_accessor :total, :primary, :secondary, :tx_fee, :proposal_reward

      # @param total [String | Integer] integer or hex number
      # @param primary [String | Integer] integer or hex number
      # @param secondary [String | Integer] integer or hex number
      # @param tx_fee [String | Integer] integer or hex number
      # @param proposal_reward [String | Integer] integer or hex number
      def initialize(total:, primary:, secondary:, tx_fee:, proposal_reward:)
        @total = Utils.to_int(total)
        @primary = Utils.to_int(primary)
        @secondary = Utils.to_int(secondary)
        @tx_fee = Utils.to_int(tx_fee)
        @proposal_reward = Utils.to_int(proposal_reward)
      end

      def to_h
        {
          total: Utils.to_hex(@total),
          primary: Utils.to_hex(@primary),
          secondary: Utils.to_hex(@secondary),
          tx_fee: Utils.to_hex(@tx_fee),
          proposal_reward: Utils.to_hex(@proposal_reward)
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
