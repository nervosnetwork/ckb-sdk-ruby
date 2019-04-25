# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "net/http"
require "json"
require "uri"

module CKB
  class RPCError < StandardError; end

  class API
    attr_reader :uri
    attr_reader :system_script_out_point
    attr_reader :system_script_cell_hash

    DEFAULT_URL = "http://localhost:8114"

    def initialize(host: DEFAULT_URL, mode: MODE::TESTNET)
      @uri = URI(host)
      if mode == MODE::TESTNET
        # For testnet chain, we can assume the first cell of the first transaction
        # in the genesis block contains default lock script we can use here.
        system_cell_transaction = genesis_block[:transactions][0]
        out_point = {
          tx_hash: system_cell_transaction[:hash],
          index: 0
        }
        cell_data = CKB::Utils.hex_to_bin(system_cell_transaction[:outputs][0][:data])
        cell_hash = CKB::Utils.bin_to_hex(CKB::Blake2b.digest(cell_data))
        set_system_script_cell(out_point, cell_hash)
      end
    end

    # @param out_point [Hash] { hash: "0x...", index: 0 }
    # @param cell_hash [String] "0x..."
    def set_system_script_cell(out_point, cell_hash)
      @system_script_out_point = out_point
      @system_script_cell_hash = cell_hash
    end

    def system_script_cell
      {
        out_point: system_script_out_point,
        cell_hash: system_script_cell_hash
      }
    end

    def genesis_block
      @genesis_block ||= get_block(genesis_block_hash)
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

    def trace_transaction(transaction)
      rpc_request("trace_transaction", params: [transaction])
    end

    def get_transaction_trace(hash)
      rpc_request("get_transaction_trace", params: [hash])
    end

    def inspect
      "\#<API@#{uri}>"
    end

    private

    def rpc_request(method, params: nil)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = {
        id: 1,
        jsonrpc: "2.0",
        method: method.to_s,
        params: params
      }.to_json
      request["Content-Type"] = "application/json"
      response = http.request(request)
      result = JSON.parse(response.body, symbolize_names: true)

      raise RPCError, "jsonrpc error: #{result[:error]}" if result[:error]

      result[:result]
    end
  end
end

# rubocop:enable Naming/AccessorMethodName
