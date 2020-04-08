# frozen_string_literal: true

module CKB
  class Config
    attr_accessor :lock_handlers, :type_handlers, :api

    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L73
    SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L127
    SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8"
    # This is my locally deployed sudt type script's code hash. This code hash will be replaced after the real sudt type script deployed on mainnet in the future
    SUDT_CODE_HASH = "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212"
    SUDT_TX_HASH = "0x0f18ac6058f7e1cef8a94b4709be58077aef1ad586403c4337226af3fb12ba29"
    HASH_TYPES = [TYPE = "type", DATA = "data"]
    # This is my locally deployed anyone can pay lock script's code hash. This code hash will be replaced after the real anyone can pay lock script deployed on mainnet in the future
    ANYONE_CAN_PAY_CODE_HASH = "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd"

    def initialize(api)
      @api = api
      @lock_handlers = {
        [SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, TYPE] => CKB::LockHandlers::SingleSignHandler.new(api),
        [SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, TYPE] => CKB::LockHandlers::MultiSignHandler.new(api),
        [ANYONE_CAN_PAY_CODE_HASH, TYPE] => CKB::LockHandlers::AnyoneCanPayHandler.new
      }
      @type_handlers = {
        [SUDT_CODE_HASH, DATA] => CKB::TypeHandlers::SudtHandler.new(SUDT_TX_HASH)
      }
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
  end
end
