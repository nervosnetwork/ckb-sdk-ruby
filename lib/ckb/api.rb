# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "net/http"
require "json"
require "uri"

module CKB
  class API
    attr_reader :rpc, :secp_group_out_point, :secp_code_out_point, :secp_data_out_point, :secp_cell_type_hash,
                :secp_cell_code_hash, :dao_out_point, :dao_code_hash, :dao_type_hash, :multi_sign_secp_cell_type_hash, :multi_sign_secp_group_out_point
    VALID_BLOCK_VERBOSITY_LEVELS = [0, 2]
    VALID_BLOCK_HEDER_VERBOSITY_LEVELS = [0, 1]
    VALID_TRANSACTION_VERBOSITY_LEVELS = [0, 1, 2]

    def initialize(host: CKB::RPC::DEFAULT_URL, mode: MODE::TESTNET, timeout_config: {})
      @rpc = CKB::RPC.new(host: host, timeout_config: timeout_config)
      if [MODE::TESTNET, MODE::MAINNET].include?(mode)
        # For testnet chain, we can assume the second cell of the first transaction
        # in the genesis block contains default lock script we can use here.
        system_cell_transaction = genesis_block.transactions.first
        cell_data = CKB::Utils.hex_to_bin(system_cell_transaction.outputs_data[1])
        code_hash = CKB::Blake2b.hexdigest(cell_data)

        @secp_cell_code_hash = code_hash

        @secp_code_out_point = Types::OutPoint.new(
          tx_hash: system_cell_transaction.hash,
          index: 1
        )
        @secp_data_out_point = Types::OutPoint.new(
          tx_hash: system_cell_transaction.hash,
          index: 3
        )

        secp_group_cell_transaction = genesis_block.transactions[1]
        secp_group_out_point = Types::OutPoint.new(
          tx_hash: secp_group_cell_transaction.hash,
          index: 0
        )

        secp_cell_type_hash = system_cell_transaction.outputs[1].type.compute_hash
        unless secp_cell_type_hash == SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
          raise "System script type_hash error!"
        end

        set_secp_group_dep(secp_group_out_point, secp_cell_type_hash)

        dao_out_point = Types::OutPoint.new(
          tx_hash: system_cell_transaction.hash,
          index: 2
        )
        dao_cell_data = CKB::Utils.hex_to_bin(system_cell_transaction.outputs_data[2])
        dao_code_hash = CKB::Blake2b.hexdigest(dao_cell_data)
        dao_type_hash = system_cell_transaction.outputs[2].type.compute_hash

        set_dao_dep(dao_out_point, dao_code_hash, dao_type_hash)

        @multi_sign_secp_cell_type_hash = system_cell_transaction.outputs[4].type.compute_hash
        @multi_sign_secp_group_out_point = Types::OutPoint.new(
          tx_hash: secp_group_cell_transaction.hash,
          index: 1
        )
      end
    end

    # @param out_point [CKB::Types::OutPoint]
    # @param secp_cell_type_hash [String] 0x...
    def set_secp_group_dep(out_point, secp_cell_type_hash)
      @secp_group_out_point = out_point
      @secp_cell_type_hash = secp_cell_type_hash
    end

    def set_dao_dep(out_point, code_hash, type_hash)
      @dao_out_point = out_point
      @dao_code_hash = code_hash
      @dao_type_hash = type_hash
    end

    def genesis_block
      @genesis_block ||= get_block_by_number(0)
    end

    def genesis_block_hash
      @genesis_block_hash ||= get_block_hash(0)
    end

    # @return [String | Integer]
    def get_block_hash(block_number)
      rpc.get_block_hash(block_number)
    end

    # @param block_hash [String] 0x...
    # @param verbosity [Integer]
    # @param with_cycles [Boolean]
    #
    # @return [CKB::Types::Block] | [CKB::Types::SerializedBlock]
    def get_block(block_hash, verbosity = 2, with_cycles = false)
      if !VALID_BLOCK_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 2"
      end

      #  https://github.com/nervosnetwork/ckb/tree/develop/rpc#method-get_block
      block_h = rpc.get_block(block_hash, verbosity, with_cycles)
      if verbosity == 2 && !with_cycles
        return Types::Block.from_h(block_h)
      end

      Types::SerializedBlock.from_h(block_h)
    end

    # @param block_number [String | Integer]
    # @param verbosity [Integer]
    # @param with_cycles [Boolean]
    #
    # @return [CKB::Types::Block] | [CKB::Types::SerializedBlock]
    def get_block_by_number(block_number, verbosity = 2, with_cycles = false)
      if !VALID_BLOCK_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 2"
      end

      block_h = rpc.get_block_by_number(block_number, verbosity, with_cycles)
      if verbosity == 2 && !with_cycles
        return Types::Block.from_h(block_h)
      end

      Types::SerializedBlock.from_h(block_h)
    end

    # @return [CKB::Types::BlockHeader]
    def get_tip_header(verbosity = 1)
      if !VALID_BLOCK_HEDER_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 1"
      end

      header_h = rpc.get_tip_header(verbosity)
      if verbosity == 1
        return Types::BlockHeader.from_h(header_h)
      end

      header_h
    end

    # @return [String]
    def get_tip_block_number
      Utils.to_int(rpc.get_tip_block_number)
    end

    # @param tx_hash [String]
    #
    # @return [CKB::Types::TransactionWithStatus]
    def get_transaction(tx_hash, verbosity = 2, only_committed = nil)
      if !VALID_TRANSACTION_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0, 1 or 2"
      end

      tx_h = rpc.get_transaction(tx_hash, verbosity)
      Types::TransactionWithStatus.from_h(tx_h, verbosity)
    end

    # @param out_point [CKB::Types::OutPoint]
    # @param with_data [Boolean]
    #
    # @return [CKB::Types::CellWithStatus]
    def get_live_cell(out_point, with_data = false)
      cell_h = rpc.get_live_cell(out_point.to_h, with_data)
      Types::CellWithStatus.from_h(cell_h)
    end

    # @param transaction [CKB::Types::Transaction]
    #
    # @return [String] tx_hash
    def send_transaction(transaction, outputs_validator = nil)
      if !outputs_validator.nil? && !%w[default passthrough].include?(outputs_validator)
        raise ArgumentError, "Invalid outputs_validator, outputs_validator should be `default` or `passthrough`"
      end

      rpc.send_transaction(transaction.to_raw_transaction_h, outputs_validator)
    end

    def _compute_transaction_hash(transaction)
      warn "[DEPRECATION] `_compute_transaction_hash` will be disabled by default from v0.40.0 and will be removed from v0.41.0."
      rpc._compute_transaction_hash(transaction.to_raw_transaction_h)
    end

    def _compute_script_hash(script)
      warn "[DEPRECATION] `_compute_script_hash` will be disabled by default from v0.40.0 and will be removed from v0.41.0."
      rpc._compute_script_hash(script.to_h)
    end

    # @return [CKB::Type::LocalNode]
    def local_node_info
      Types::LocalNode.from_h(
        rpc.local_node_info
      )
    end

    # @return [CKB::Types::Epoch]
    def get_current_epoch
      Types::Epoch.from_h(rpc.get_current_epoch)
    end

    # @param number [Integer | String]
    #
    # @return [CKB::Types::Epoch]
    def get_epoch_by_number(number)
      Types::Epoch.from_h(
        rpc.get_epoch_by_number(number)
      )
    end

    # @return [CKB::Types::Peer[]]
    def get_peers
      rpc.get_peers.map { |peer| Types::Peer.from_h(peer) }
    end

    # @return [CKB::Types::TxPoolInfo]
    def tx_pool_info
      Types::TxPoolInfo.from_h(
        rpc.tx_pool_info
      )
    end

    # @return [CKB::Types::BlockEconomyState]
    def get_block_economic_state(block_hash)
      Types::BlockEconomicState.from_h(
        rpc.get_block_economic_state(block_hash)
      )
    end

    # @return [CKB::Types::ChainInfo]
    def get_blockchain_info
      Types::ChainInfo.from_h(
        rpc.get_blockchain_info
      )
    end

    # @return [CKB::Types::PeerState[]]
    def get_peers_state
      warn "[DEPRECATION] `get_peers_state` will be disabled by default from v0.40.0 and will be removed from v0.41.0."
      rpc.get_peers_state.map { |peer| Types::PeerState.from_h(peer) }
    end

    # @param transaction [CKB::Types::Transaction]
    #
    # @return [CKB::Types::DryRunResult]
    def dry_run_transaction(transaction)
      result = rpc.dry_run_transaction(transaction.to_raw_transaction_h)
      Types::DryRunResult.from_h(result)
    end

    # @param out_point [CKB::Types::OutPoint]
    # @param hash [String]
    #
    # @return [String]
    def calculate_dao_maximum_withdraw(out_point, hash)
      rpc.calculate_dao_maximum_withdraw(out_point.to_h, hash)
    end

    # @param block_hash [String] 0x...
    #
    # @return [CKB::Types::BlockHeader] | [String]
    def get_header(block_hash, verbosity = 1)
      if !VALID_BLOCK_HEDER_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 1"
      end

      block_header_h = rpc.get_header(block_hash, verbosity)
      if verbosity == 1
        return Types::BlockHeader.from_h(block_header_h)
      end

      block_header_h
    end

    # @param block_number [String | Integer]
    #
    # @return [CKB::Types::BlockHeader] | [String]
    def get_header_by_number(block_number, verbosity = 1)
       if !VALID_BLOCK_HEDER_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 1"
      end

      block_header_h = rpc.get_header_by_number(block_number, verbosity)
      if verbosity == 1
        return Types::BlockHeader.from_h(block_header_h)
      end

      block_header_h
    end

    # @param block_hash [String] 0x...
    #
    # @return [CKB::Types::BlockReward]
    def get_cellbase_output_capacity_details(block_hash)
      warn "[DEPRECATION] `get_cellbase_output_capacity_details` will be disabled by default from v0.40.0 and will be removed from v0.41.0."
      block_reward_h = rpc.get_cellbase_output_capacity_details(block_hash)
      Types::BlockReward.from_h(block_reward_h)
    end

    # @param address [String]
    # @param command [String]
    # @param ban_time [String | nil] timestamp
    # @param absolute [Boolean | nil]
    # @param reason [String | nil]
    def set_ban(address, command, ban_time = nil, absolute = nil, reason = nil)
      rpc.set_ban(address, command, ban_time, absolute, reason)
    end

    # @return [CKB::Types::BannedAddress[]]
    def get_banned_addresses
      result = rpc.get_banned_addresses
      result.map { |addr| Types::BannedAddress.from_h(addr) }
    end

    # @param bytes_limit [String | Integer] integer or hex number
    # @param proposals_limit [String | Integer] integer or hex number
    # @param max_version [String | Integer] integer or hex number
    # @return block_template [BlockTemplate]
    def get_block_template(bytes_limit: nil, proposals_limit: nil, max_version: nil)
      block_template_h = rpc.get_block_template(bytes_limit, proposals_limit, max_version)
      Types::BlockTemplate.from_h(block_template_h)
    end

    # @param work_id [String | Integer] integer or hex number
    # @param raw_block_h [hash]
    # @return block_hash [String]
    def submit_block(work_id: nil, raw_block_h: nil)
      rpc.submit_block(work_id, raw_block_h)
    end

    def batch_request(*requests)
      rpc.batch_request(*requests)
    end

    def clear_tx_pool
      rpc.clear_tx_pool
    end

    def get_raw_tx_pool(verbose = false)
      rs = rpc.get_raw_tx_pool(verbose)
      if verbose
        Types::TxPoolVerbosity.from_h(rs)
      else
        Types::TxPoolIds.from_h(rs)
      end
    end

    def get_consensus
      Types::Consensus.from_h(rpc.get_consensus)
    end

    # @return sync_state [SyncState]
    def sync_state
      Types::SyncState.from_h(rpc.sync_state)
    end

    # @param state [Boolean]
    # @return nil
    def set_network_active(state)
      rpc.set_network_active(state)
    end

    # @param peer_id [String]
    # @param address [String]
    # @return nil
    def add_node(peer_id:, address:)
      rpc.add_node(peer_id, address)
    end

    def remove_node(peer_id)
      rpc.remove_node(peer_id)
    end

    def ping_peers
      rpc.ping_peers
    end

    # @param tx_hashes [string[]]
    # @param block_hash [string]
    def get_transaction_proof(tx_hashes:, block_hash: nil)
      transaction_proof_h = rpc.get_transaction_proof(tx_hashes, block_hash)
      CKB::Types::TransactionProof.from_h(transaction_proof_h)
    end

    # @param proof [CKB::Types::TransactionProof]
    def verify_transaction_proof(proof)
      rpc.verify_transaction_proof(proof.to_h)
    end

    def clear_banned_addresses
      rpc.clear_banned_addresses
    end


    # @param block_template [CKB::Types::BlockTemplate]
    # @return block_hash [string]
    def generate_block_with_template(block_template)
      rpc.generate_block_with_template(block_template.to_h)
    end

    # @param alert [CKB::Types::Alert]
    def send_alert(alert)
      rpc.send_alert(alert)
    end

    # @param block_hash [string]
    def get_block_filter(block_hash)
      Types::BlockFilter.from_h(rpc.get_block_filter(block_hash))
    end

    # @param tx_hashes [string[]]
    # @param block_hash [string]
    def get_transaction_and_witness_proof(tx_hashes:, block_hash: nil)
      transaction_and_witness_proof_h = rpc.get_transaction_and_witness_proof(tx_hashes, block_hash)
      CKB::Types::TransactionAndWitnessProof.from_h(transaction_and_witness_proof_h)
    end

    # @param proof [CKB::Types::TransactionAndWitnessProof]
    def verify_transaction_and_witness_proof(proof)
      rpc.verify_transaction_and_witness_proof(proof.to_h)
    end

    # @param block_hash [string]
    # @param verbosity [Integer]
    def get_fork_block(block_hash, verbosity = 2)
      if !VALID_BLOCK_VERBOSITY_LEVELS.include?(verbosity)
        raise ArgumentError, "Invalid verbosity, verbosity should be 0 or 2"
      end

      block_h = rpc.get_fork_block(block_hash, verbosity)
      if verbosity == 2
        return Types::Block.from_h(block_h)
      end

      Types::SerializedBlock.from_h(block_h)
    end

    # @param block_hash [string]
    # @return block_median_time [string]
    def get_block_median_time(block_hash)
      rpc.get_block_median_time(block_hash)
    end

    # @param tx [CKB::Types::Transaction]
    def estimate_cycles(tx)
      rs = rpc.estimate_cycles(tx.to_raw_transaction_h)
      unless rs.nil?
        rs[:cycles]
      end
    end

    # @param target [Integer]
    def get_fee_rate_statistics(target = 21)
      if target < 1 || target > 101
        raise ArgumentError, "Invalid target, target should be 1 ~ 101"
      end
      rs = rpc.get_fee_rate_statistics(target)
      Types::FeeRateStatistics.from_h(rs)
    end

    def get_indexer_tip
      rs = rpc.get_indexer_tip
      Types::IndexerTip.from_h(rs)
    end

    def tx_pool_ready
      rpc.tx_pool_ready
    end

    def get_deployments_info
      rpc.get_deployments_info
    end

    def inspect
      "\#<API@#{rpc.uri}>"
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
