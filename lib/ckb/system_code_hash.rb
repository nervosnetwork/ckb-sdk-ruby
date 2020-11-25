# frozen_string_literal: true

module CKB
  module SystemCodeHash
    SECP256K1_BLAKE160_SIGHASH_ALL_DATA_HASH = "0x973bdb373cbb1d752b4ac006e2bb5bdcb63431ed2b6e394b22721c8906a2ad72"
    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L73
    SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
    # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/mainnet.toml#L127
    SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8"
    ANYONE_CAN_PAY_CODE_HASH_ON_LINA = "0xd369597ff47f29fbc0d47d2e3775370d1250b85140c670e4718af712983a2354"
    ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON = "0x3419a1c09eb2567f6552ee7a8ecffd64155cffe0f1796e6e61ec088d740c1356"
  end
end
