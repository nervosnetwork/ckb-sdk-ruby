# frozen_string_literal: true

module CKB
  module Types
    class BlockEconomicState
      attr_accessor :issuance, :miner_reward, :txs_fee, :finalized_at

      # @param issuance [CKB::Types::BlockIssuance]
      # @param miner_reward [CKB::Types::MinerReward]
      # @param txs_fee [String | Integer]
      # @param finalized_at [String]
      def initialize(
        issuance:,
        miner_reward:,
        txs_fee:,
        finalized_at:
      )
        @issuance = issuance
        @miner_reward = miner_reward
        @txs_fee = Utils.to_int(txs_fee)
        @finalized_at = finalized_at
      end

      def to_h
        {
          issuance: issuance.to_h,
          miner_reward: miner_reward.to_h,
          txs_fee: Utils.to_hex(txs_fee),
          finalized_at: finalized_at
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          issuance: CKB::Types::BlockIssuance.from_h(hash[:issuance]),
          miner_reward: CKB::Types::MinerReward.from_h(hash[:miner_reward]),
          txs_fee: Utils.to_int(hash[:txs_fee]),
          finalized_at: hash[:finalized_at]
        )
      end
    end
  end
end
