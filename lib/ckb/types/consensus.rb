# frozen_string_literal: true

module CKB
  module Types
    class Consensus
      attr_accessor :id, :genesis_hash, :dao_type_hash, :secp256k1_blake160_sighash_all_type_hash, :secp256k1_blake160_multisig_all_type_hash, :initial_primary_epoch_reward, :secondary_epoch_reward, :max_uncles_num,
                    :orphan_rate_target, :epoch_duration_target, :tx_proposal_window, :proposer_reward_ratio, :cellbase_maturity, :median_time_block_count, :max_block_cycles, :max_block_bytes, :block_version, :tx_version,
                    :type_id_code_hash, :max_block_proposals_limit, :primary_epoch_reward_halving_interval, :permanent_difficulty_in_dummy, :hardfork_features

      # @param id [String]
      # @param genesis_hash [String]
      # @param dao_type_hash [String]
      # @param secp256k1_blake160_sighash_all_type_hash [String]
      # @param secp256k1_blake160_multisig_all_type_hash [String]
      # @param initial_primary_epoch_reward [Integer | String]
      # @param secondary_epoch_reward [Integer | String]
      # @param max_uncles_num [Integer | String]
      # @param orphan_rate_target [CKB::Types::RationalU256]
      # @param epoch_duration_target [Integer | String]
      # @param tx_proposal_window [CKB::Types::ProposalWindow]
      # @param proposer_reward_ratio [CKB::Types::RationalU256]
      # @param cellbase_maturity [String]
      # @param median_time_block_count [Integer | String]
      # @param max_block_cycles [Integer | String]
      # @param max_block_bytes [Integer | String]
      # @param block_version [Integer | String]
      # @param tx_version [Integer | String]
      # @param type_id_code_hash [String]
      # @param max_block_proposals_limit [Integer | String]
      # @param primary_epoch_reward_halving_interval [Integer | String]
      # @param permanent_difficulty_in_dummy [Boolean]
      # @param hardfork_features [CKB::Types::HardForkFeature]
      def initialize(id:, genesis_hash:, dao_type_hash:, secp256k1_blake160_sighash_all_type_hash:, secp256k1_blake160_multisig_all_type_hash:, initial_primary_epoch_reward:, secondary_epoch_reward:, max_uncles_num:, orphan_rate_target:, epoch_duration_target:,
                     tx_proposal_window:, proposer_reward_ratio:, cellbase_maturity:, median_time_block_count:, max_block_cycles:, max_block_bytes:, block_version:, tx_version:, type_id_code_hash:, max_block_proposals_limit:, primary_epoch_reward_halving_interval:, permanent_difficulty_in_dummy:, hardfork_features:)
        @id = id
        @genesis_hash = genesis_hash
        @dao_type_hash = dao_type_hash
        @secp256k1_blake160_sighash_all_type_hash = secp256k1_blake160_sighash_all_type_hash
        @secp256k1_blake160_multisig_all_type_hash = secp256k1_blake160_multisig_all_type_hash
        @initial_primary_epoch_reward = CKB::Utils.to_int(initial_primary_epoch_reward)
        @secondary_epoch_reward = CKB::Utils.to_int(secondary_epoch_reward)
        @max_uncles_num = CKB::Utils.to_int(max_uncles_num)
        @orphan_rate_target = orphan_rate_target
        @epoch_duration_target = CKB::Utils.to_int(epoch_duration_target)
        @tx_proposal_window = tx_proposal_window
        @proposer_reward_ratio = proposer_reward_ratio
        @cellbase_maturity = cellbase_maturity
        @median_time_block_count = CKB::Utils.to_int(median_time_block_count)
        @max_block_cycles = CKB::Utils.to_int(max_block_cycles)
        @max_block_bytes = CKB::Utils.to_int(max_block_bytes)
        @block_version = CKB::Utils.to_int(block_version)
        @tx_version = CKB::Utils.to_int(tx_version)
        @type_id_code_hash = type_id_code_hash
        @max_block_proposals_limit = CKB::Utils.to_int(max_block_proposals_limit)
        @primary_epoch_reward_halving_interval = CKB::Utils.to_int(primary_epoch_reward_halving_interval)
        @permanent_difficulty_in_dummy = permanent_difficulty_in_dummy
        @hardfork_features = hardfork_features
      end

      def to_h
        {
          id: id,
          genesis_hash: genesis_hash,
          dao_type_hash: dao_type_hash,
          secp256k1_blake160_sighash_all_type_hash: secp256k1_blake160_sighash_all_type_hash,
          secp256k1_blake160_multisig_all_type_hash: secp256k1_blake160_multisig_all_type_hash,
          initial_primary_epoch_reward: CKB::Utils.to_hex(initial_primary_epoch_reward),
          secondary_epoch_reward: CKB::Utils.to_hex(secondary_epoch_reward),
          max_uncles_num: CKB::Utils.to_hex(max_uncles_num),
          orphan_rate_target: orphan_rate_target.to_h,
          epoch_duration_target: CKB::Utils.to_hex(epoch_duration_target),
          tx_proposal_window: tx_proposal_window.to_h,
          proposer_reward_ratio: proposer_reward_ratio.to_h,
          cellbase_maturity: cellbase_maturity,
          median_time_block_count: CKB::Utils.to_hex(median_time_block_count),
          max_block_cycles: CKB::Utils.to_hex(max_block_cycles),
          max_block_bytes: CKB::Utils.to_hex(max_block_bytes),
          block_version: CKB::Utils.to_hex(block_version),
          tx_version: CKB::Utils.to_hex(tx_version),
          type_id_code_hash: type_id_code_hash,
          max_block_proposals_limit: CKB::Utils.to_hex(max_block_proposals_limit),
          primary_epoch_reward_halving_interval: CKB::Utils.to_hex(primary_epoch_reward_halving_interval),
          permanent_difficulty_in_dummy: permanent_difficulty_in_dummy,
          hardfork_features: hardfork_features.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          id: hash[:id],
          genesis_hash: hash[:genesis_hash],
          dao_type_hash: hash[:dao_type_hash],
          secp256k1_blake160_sighash_all_type_hash: hash[:secp256k1_blake160_sighash_all_type_hash],
          secp256k1_blake160_multisig_all_type_hash: hash[:secp256k1_blake160_multisig_all_type_hash],
          initial_primary_epoch_reward: hash[:initial_primary_epoch_reward],
          secondary_epoch_reward: hash[:secondary_epoch_reward],
          max_uncles_num: hash[:max_uncles_num],
          orphan_rate_target: CKB::Types::RationalU256.from_h(hash[:orphan_rate_target]),
          epoch_duration_target: hash[:epoch_duration_target],
          tx_proposal_window: CKB::Types::ProposalWindow.from_h(hash[:tx_proposal_window]),
          proposer_reward_ratio: CKB::Types::RationalU256.from_h(hash[:proposer_reward_ratio]),
          cellbase_maturity: hash[:cellbase_maturity],
          median_time_block_count: hash[:median_time_block_count],
          max_block_cycles: hash[:max_block_cycles],
          max_block_bytes: hash[:max_block_bytes],
          block_version: hash[:block_version],
          tx_version: hash[:tx_version],
          type_id_code_hash: hash[:type_id_code_hash],
          max_block_proposals_limit: hash[:max_block_proposals_limit],
          primary_epoch_reward_halving_interval: hash[:primary_epoch_reward_halving_interval],
          permanent_difficulty_in_dummy: hash[:permanent_difficulty_in_dummy],
          hardfork_features: hash[:hardfork_features].map { |hardfork_feature| CKB::Types::HardForkFeature.from_h(hardfork_feature) }
        )
      end
    end
  end
end
