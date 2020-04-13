# frozen_string_literal: true
require "singleton"

module CKB
  class Config
    include Singleton
    attr_accessor :lock_handlers, :type_handlers, :sudt_info, :anyone_can_pay_info
    attr_reader :api

    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L73
    SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L127
    SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8"
    HASH_TYPES = [TYPE = "type", DATA = "data"]

    def initialize
      @lock_handlers = {
        [SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, TYPE] => CKB::LockHandlers::SingleSignHandler.new(api),
        [SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, TYPE] => CKB::LockHandlers::MultiSignHandler.new(api),
      }
      @type_handlers = {}
      set_api(CKB::RPC::DEFAULT_URL)
    end

    def lock_handler(lock_script)
      lock_handlers[[lock_script.code_hash, lock_script.hash_type]]
    end

    def type_handler(type_script)
      type_handlers[[type_script.code_hash, type_script.hash_type]]
    end

    def standard_secp256k1_blake160_sighash_all_cell_dep
      CKB::Types::CellDep.new(
        out_point: api.secp_group_out_point,
        dep_type: "dep_group"
      )
    end

    def standard_secp256k1_blake160_multisig_all
      CKB::Types::CellDep.new(
        out_point: api.multi_sign_secp_group_out_point,
        dep_type: "dep_group"
      )
    end

    def set_api(api_url, mode = MODE::TESTNET)
      @api_url = api_url
      @api = CKB::API.new(host: @api_url, mode: mode)
    end


    def sudt_info
      @sudt_info || {}
    end

    # { code_hash: "", tx_hash: "" }
    def anyone_can_pay_info
      @anyone_can_pay_info || {}
    end
  end
end
