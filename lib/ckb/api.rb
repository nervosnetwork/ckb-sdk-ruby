# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "net/http"
require "json"
require "uri"

module CKB
  class API
    attr_reader :rpc
    attr_reader :system_script_out_point
    attr_reader :system_script_code_hash

    def initialize(host: CKB::RPC::DEFAULT_URL, mode: MODE::TESTNET)
      @rpc = CKB::RPC.new(host: host)
      if mode == MODE::TESTNET
        # Testnet system script code_hash
        expected_code_hash = "0xa4a3d87cd69733562865ddfaf12dd44cf4cd396c4128ff1a5839c2fe48b2a1a1"
        # For testnet chain, we can assume the second cell of the first transaction
        # in the genesis block contains default lock script we can use here.
        system_cell_transaction = genesis_block.transactions.first
        out_point = Types::OutPoint.new(
          cell: Types::CellOutPoint.new(
            tx_hash: system_cell_transaction.hash,
            index: "1"
          )
        )
        cell_data = CKB::Utils.hex_to_bin(system_cell_transaction.outputs[1].data)
        code_hash = CKB::Utils.bin_to_hex(CKB::Blake2b.digest(cell_data))

        raise "System script code_hash error!" unless code_hash == expected_code_hash

        set_system_script_cell(out_point, code_hash)
      end
    end

    # @param out_point [CKB::Types::OutPoint]
    # @param code_hash [String] "0x..."
    def set_system_script_cell(out_point, code_hash)
      @system_script_out_point = out_point
      @system_script_code_hash = code_hash
    end

    def system_script_cell
      {
        out_point: system_script_out_point,
        code_hash: system_script_code_hash
      }
    end

    def genesis_block
      @genesis_block ||= get_block_by_number("0")
    end

    def genesis_block_hash
      @genesis_block_hash ||= get_block_hash("0")
    end

    # @return [String | Integer]
    def get_block_hash(block_number)
      rpc.get_block_hash(block_number.to_s)
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
      block_h = rpc.get_block_by_number(block_number.to_s)
      Types::Block.from_h(block_h)
    end

    # @return [CKB::Types::BlockHeader]
    def get_tip_header
      header_h = rpc.get_tip_header
      Types::BlockHeader.from_h(header_h)
    end

    # @return [String]
    def get_tip_block_number
      rpc.get_tip_block_number
    end

    # @param hash [String] 0x...
    # @param from [String | Integer]
    # @param to [String | Integer]
    #
    # @return [CKB::Types::Output[]]
    def get_cells_by_lock_hash(hash, from, to)
      outputs = rpc.get_cells_by_lock_hash(hash, from.to_s, to.to_s)
      outputs.map { |output| Types::Output.from_h(output) }
    end

    # @param tx_hash [String]
    #
    # @return [CKB::Types::TransactionWithStatus]
    def get_transaction(tx_hash)
      tx_h = rpc.get_transaction(tx_hash)
      Types::TransactionWithStatus.from_h(tx_h)
    end

    # @param out_point [CKB::Types::OutPoint]
    #
    # @return [CKB::Types::CellWithStatus]
    def get_live_cell(out_point)
      cell_h = rpc.get_live_cell(out_point.to_h)
      Types::CellWithStatus.from_h(cell_h)
    end

    # @param transaction [CKB::Types::Transaction]
    #
    # @return [String] tx_hash
    def send_transaction(transaction)
      rpc.send_transaction(transaction.to_h)
    end

    def compute_transaction_hash(transaction)
      rpc.compute_transaction_hash(transaction.to_h)
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
      result = rpc.dry_run_transaction(transaction.to_h)
      Types::DryRunResult.from_h(result)
    end

    # @param out_point [CKB::Types::OutPoint]
    # @param hash [String]
    #
    # @return [String]
    def calculate_dao_maximum_withdraw(out_point, hash)
      rpc.calculate_dao_maximum_withdraw(out_point.to_h, hash)
    end

    def inspect
      "\#<API@#{rpc.uri}>"
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
