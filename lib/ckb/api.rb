# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "net/http"
require "json"
require "uri"

module CKB
  class API
    attr_reader :rpc
    attr_reader :secp_group_out_point
    attr_reader :secp_code_out_point
    attr_reader :secp_data_out_point
    attr_reader :secp_cell_type_hash
    attr_reader :secp_cell_code_hash
    attr_reader :dao_out_point
    attr_reader :dao_code_hash
    attr_reader :dao_type_hash

    attr_reader :multi_sign_secp_cell_type_hash
    attr_reader :multi_sign_secp_group_out_point

    def initialize(host: CKB::RPC::DEFAULT_URL, mode: MODE::TESTNET)
      @rpc = CKB::RPC.new(host: host)
      if mode == MODE::TESTNET
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
        raise "System script type_hash error!" unless secp_cell_type_hash == SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
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
    #
    # @return [CKB::Types::Block]
    def get_block(block_hash)
      block_h = rpc.get_block(block_hash)
      Types::Block.from_h(block_h)
    end

    # @param block_number [String | Integer]
    #
    # @return [CKB::Types::Block]
    def get_block_by_number(block_number)
      block_h = rpc.get_block_by_number(block_number)
      Types::Block.from_h(block_h)
    end

    # @return [CKB::Types::BlockHeader]
    def get_tip_header
      header_h = rpc.get_tip_header
      Types::BlockHeader.from_h(header_h)
    end

    # @return [String]
    def get_tip_block_number
      Utils.to_int(rpc.get_tip_block_number)
    end

    # @param hash [String] 0x...
    # @param from [String | Integer]
    # @param to [String | Integer]
    #
    # @return [CKB::Types::CellOutputWithOutPoint[]]
    def get_cells_by_lock_hash(hash, from, to)
      outputs = rpc.get_cells_by_lock_hash(hash, from, to)
      outputs.map { |output| Types::CellOutputWithOutPoint.from_h(output) }
    end

    # @param tx_hash [String]
    #
    # @return [CKB::Types::TransactionWithStatus]
    def get_transaction(tx_hash)
      tx_h = rpc.get_transaction(tx_hash)
      Types::TransactionWithStatus.from_h(tx_h)
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
    def send_transaction(transaction)
      rpc.send_transaction(transaction.to_raw_transaction_h)
    end

    def compute_transaction_hash(transaction)
      rpc.compute_transaction_hash(transaction.to_raw_transaction_h)
    end

    def compute_script_hash(script)
      rpc.compute_script_hash(script.to_h)
    end

    # @return [CKB::Type::Peer]
    def local_node_info
      Types::Peer.from_h(
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

    # @return [CKB::Types::ChainInfo]
    def get_blockchain_info
      Types::ChainInfo.from_h(
        rpc.get_blockchain_info
      )
    end

    # @return [CKB::Types::PeerState[]]
    def get_peers_state
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

    # Indexer

    # @param lock_hash [String]
    def deindex_lock_hash(lock_hash)
      rpc.deindex_lock_hash(lock_hash)
    end

    # @param lock_hash [String]
    # @param page [String]
    # @param per [String]
    # @param reverse_order [Boolean]
    #
    # @return [Types::LiveCell[]]
    def get_live_cells_by_lock_hash(lock_hash, page, per, reverse_order: false)
      result = rpc.get_live_cells_by_lock_hash(lock_hash, page, per, reverse_order: reverse_order)
      result.map { |live_cell| Types::LiveCell.from_h(live_cell) }
    end

    # @return [Types::LockHashIndexState[]]
    def get_lock_hash_index_states
      result = rpc.get_lock_hash_index_states
      result.map { |state| Types::LockHashIndexState.from_h(state) }
    end

    # @param lock_hash [String]
    # @param page [String]
    # @param per [String]
    # @param reverse_order [Boolean]
    #
    # @return [Types::CellTransaction[]]
    def get_transactions_by_lock_hash(lock_hash, page, per, reverse_order: false)
      result = rpc.get_transactions_by_lock_hash(lock_hash, page, per, reverse_order: reverse_order)
      result.map { |cell_tx| Types::CellTransaction.from_h(cell_tx) }
    end

    # @param lock_hash [String]
    # @param index_from [String]
    #
    # @return [Types::LockHashIndexState]
    def index_lock_hash(lock_hash, index_from: 0)
      state = rpc.index_lock_hash(lock_hash, index_from: index_from)
      Types::LockHashIndexState.from_h(state)
    end

    # @param block_hash [String] 0x...
    #
    # @return [CKB::Types::BlockHeader]
    def get_header(block_hash)
      block_header_h = rpc.get_header(block_hash)
      Types::BlockHeader.from_h(block_header_h)
    end

    # @param block_number [String | Integer]
    #
    # @return [CKB::Types::BlockHeader]
    def get_header_by_number(block_number)
      block_header_h = rpc.get_header_by_number(block_number)
      Types::BlockHeader.from_h(block_header_h)
    end

    # @param block_hash [String] 0x...
    #
    # @return [CKB::Types::BlockReward]
    def get_cellbase_output_capacity_details(block_hash)
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

    # @param expect_confirm_blocks [Integer]
    def estimate_fee_rate(expect_confirm_blocks)
      result = rpc.estimate_fee_rate(expect_confirm_blocks)
      Types::EstimateResult.from_h(result)
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

    def inspect
      "\#<API@#{rpc.uri}>"
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
