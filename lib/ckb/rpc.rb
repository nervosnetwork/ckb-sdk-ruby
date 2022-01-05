# frozen_string_literal: true

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
    DEFAULT_INDEXER_URL = "http://localhost:8116"

    def initialize(host: DEFAULT_URL, timeout_config: {})
      @uri = URI(host)
      @http = Net::HTTP::Persistent.new
      @http.open_timeout = timeout_config[:open_timeout] if timeout_config[:open_timeout]
      @http.read_timeout = timeout_config[:read_timeout] if timeout_config[:read_timeout]
      @http.write_timeout = timeout_config[:write_timeout] if timeout_config[:write_timeout]
    end

    def method_missing(method, *params)
      single_request(method, params)
    end

    def genesis_block
      @genesis_block ||= get_block_by_number(0)
    end

    def genesis_block_hash
      @genesis_block_hash ||= get_block_hash(0)
    end

    def send_transaction(transaction, outputs_validator = nil)
      if !outputs_validator.nil? && !%w[default passthrough].include?(outputs_validator)
        raise ArgumentError, "Invalid outputs_validator, outputs_validator should be `default` or `passthrough`"
      end

      single_request("send_transaction", [transaction, outputs_validator])
    end

    def inspect
      "\#<RPC@#{uri}>"
    end

    def batch_request(*requests)
      body = requests.map do |request|
        { id: SecureRandom.uuid, jsonrpc: "2.0", method: request[0], params: request[1..-1].map do |param|
                                                                               param.is_a?(Integer) ? Utils.to_hex(param) : param
                                                                             end }
      end
      parsed_response = parse_response(post(body))
      errors = parsed_response.select { |response| response[:error] }
      raise RPCError, errors unless errors.empty?

      parsed_response.map { |response| response[:result] }
    end

    private

    def single_request(method, params)
      response = post(id: SecureRandom.uuid, jsonrpc: "2.0", method: method, params: params.map do |param|
                                                                                       param.is_a?(Integer) ? Utils.to_hex(param) : param
                                                                                     end)
      parsed_response = parse_response(response)
      raise RPCError, "jsonrpc error: #{parsed_response[:error]}, code: #{parsed_response[:code]}" if parsed_response[:error]

      parsed_response[:result]
    end

    def post(body)
      request = Net::HTTP::Post.new(uri.path)
      request.body = body.to_json
      request["Content-Type"] = "application/json"
      http.request(uri, request)
    end

    def parse_response(response)
      if response.code == "200"
        JSON.parse(response.body, symbolize_names: true)
      else
        { error: response.body, code: response.code }
      end
    end
  end
end
