# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

# hotfix for Windows
if Gem.win_platform?
  module Process
    class << self
      alias orig_getrlimit getrlimit
      def getrlimit(resource)
        return [1024] if resource == Process::RLIMIT_NOFILE

        orig_getrlimit(resource)
      end
    end
  end
end

require "net/http/persistent"
require "json"
require "uri"

module CKB
  class RPCError < StandardError; end

  class RPC
    attr_reader :uri, :http

    DEFAULT_URL = "http://localhost:8114"

    def initialize(host: DEFAULT_URL)
      @uri = URI(host)
      @http = Net::HTTP::Persistent.new
    end

    def genesis_block
      @genesis_block ||= get_block_by_number("0")
    end

    def genesis_block_hash
      @genesis_block_hash ||= get_block_hash("0")
    end

    def get_block_hash(block_number)
      rpc_request("get_block_hash", params: [block_number])
    end

    def get_block(block_hash)
      rpc_request("get_block", params: [block_hash])
    end

    def get_block_by_number(block_number)
      rpc_request("get_block_by_number", params: [block_number.to_s])
    end

    def get_tip_header
      rpc_request("get_tip_header")
    end

    def get_tip_block_number
      rpc_request("get_tip_block_number")
    end

    def get_cells_by_lock_hash(hash, from, to)
      rpc_request("get_cells_by_lock_hash", params: [hash, from, to])
    end

    def get_transaction(tx_hash)
      rpc_request("get_transaction", params: [tx_hash])
    end

    def get_live_cell(out_point)
      rpc_request("get_live_cell", params: [out_point])
    end

    def send_transaction(transaction)
      rpc_request("send_transaction", params: [transaction])
    end

    def local_node_info
      rpc_request("local_node_info")
    end

    def get_current_epoch
      rpc_request("get_current_epoch")
    end

    def get_epoch_by_number(number)
      rpc_request("get_epoch_by_number", params: [number.to_s])
    end

    # @return [Hash[]]
    def get_peers
      rpc_request("get_peers")
    end

    # @return [Hash]
    def tx_pool_info
      rpc_request("tx_pool_info")
    end

    def get_blockchain_info
      rpc_request("get_blockchain_info")
    end

    def get_peers_state
      rpc_request("get_peers_state")
    end

    def compute_transaction_hash(transaction)
      rpc_request("_compute_transaction_hash", params: [transaction])
    end

    # @param transaction [Hash]
    def dry_run_transaction(transaction)
      rpc_request("dry_run_transaction", params: [transaction])
    end

    def calculate_dao_maximum_withdraw(out_point, hash)
      rpc_request("calculate_dao_maximum_withdraw", params: [out_point, hash])
    end

    # Indexer

    # @param lock_hash [String]
    def deindex_lock_hash(lock_hash)
      rpc_request("deindex_lock_hash", params: [lock_hash])
    end

    def get_live_cells_by_lock_hash(lock_hash, page, per, reverse_order: false)
      rpc_request("get_live_cells_by_lock_hash", params: [lock_hash, page.to_s, per.to_s, reverse_order])
    end

    def get_lock_hash_index_states
      rpc_request("get_lock_hash_index_states")
    end

    def get_transactions_by_lock_hash(lock_hash, page, per, reverse_order: false)
      rpc_request("get_transactions_by_lock_hash", params: [lock_hash, page.to_s, per.to_s, reverse_order])
    end

    def index_lock_hash(lock_hash, index_from: '0')
      rpc_request("index_lock_hash", params: [lock_hash, index_from.to_s])
    end

    def get_header(block_hash)
      rpc_request("get_header", params: [block_hash])
    end

    def get_header_by_number(block_number)
      rpc_request("get_header_by_number", params: [block_number.to_s])
    end

    def get_cellbase_output_capacity_details(block_hash)
      rpc_request("get_cellbase_output_capacity_details", params: [block_hash])
    end

    # @param address [String]
    # @param command [String]
    # @param ban_time [String | nil] timestamp
    # @param absolute [Boolean | nil]
    # @param reason [String | nil]
    def set_ban(address, command, ban_time = nil, absolute = nil, reason = nil)
      rpc_request("set_ban", params: [address, command, ban_time, absolute, reason])
    end

    def get_banned_addresses
      rpc_request("get_banned_addresses")
    end

    def inspect
      "\#<RPC@#{uri}>"
    end

    private

    def rpc_request(method, params: nil)
      request = Net::HTTP::Post.new("/")
      request.body = {
        id: 1,
        jsonrpc: "2.0",
        method: method.to_s,
        params: params
      }.to_json
      request["Content-Type"] = "application/json"
      response = http.request(uri, request)
      result = JSON.parse(response.body, symbolize_names: true)

      raise RPCError, "jsonrpc error: #{result[:error]}" if result[:error]

      result[:result]
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
