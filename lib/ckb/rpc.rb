# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

require "net/http"
require "json"
require "uri"

module CKB
  class RPCError < StandardError; end

  class RPC
    attr_reader :uri

    DEFAULT_URL = "http://localhost:8114"

    def initialize(host: DEFAULT_URL)
      @uri = URI(host)
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

    def trace_transaction(transaction)
      rpc_request("trace_transaction", params: [transaction])
    end

    def get_transaction_trace(hash)
      rpc_request("get_transaction_trace", params: [hash])
    end

    def inspect
      "\#<RPC@#{uri}>"
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
