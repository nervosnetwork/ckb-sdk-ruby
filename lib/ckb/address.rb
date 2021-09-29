# frozen_string_literal: true

module CKB
  class Address
    attr_reader :script, :prefix, :mode, :version

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"
    DEFAULT_MODE = MODE::TESTNET
    FULL_WITH_IDENTIFIER_FORMAT = "00"
    SHORT_FORMAT = "01"
    FULL_DATA_FORMAT = "02"
    FULL_TYPE_FORMAT = "04"
    CODE_HASH_INDEX_SINGLESIG = "00"
    CODE_HASH_INDEX_MULTISIG_SIG = "01"
    CODE_HASH_INDEX_ANYONE_CAN_PAY = "02"
    SHORT_PAYLOAD_AVAILABLE_ARGS_LEN = [20, 21, 22].freeze

    module Version
      CKB2019 = 1
      CKB2021 = 2
    end

    # @param script [CKB::Types::Script]
    # @param mode [String]
    def initialize(script, mode: DEFAULT_MODE, version: CKB::Address::Version::CKB2021)
      @script = script
      @mode = mode
      @prefix = self.class.prefix(mode: mode)
      @version = version
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | code hash index(00) | pubkey blake160
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    def generate
      unless CKB::ScriptHashType::TYPE == script.hash_type && script.has_args? && SHORT_PAYLOAD_AVAILABLE_ARGS_LEN.include?(CKB::Utils.hex_to_bin(script.args).bytesize)
        return generate_full_payload_address
      end

      if SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH == script.code_hash
        generate_short_payload_singlesig_address
      elsif SystemCodeHash::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH == script.code_hash
        generate_short_payload_multisig_address
      elsif [SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA,
             SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON].include?(script.code_hash)
        generate_short_payload_anyone_can_pay_address
      else
        generate_full_payload_address
      end
    end

    alias to_s generate

    def self.prefix(mode: DEFAULT_MODE)
      case mode
      when MODE::TESTNET
        PREFIX_TESTNET
      when MODE::MAINNET
        PREFIX_MAINNET
      else
        raise InvalidModeError, "Invalid mode"
      end
    end

    private

    def short_payload(code_hash_index)
      blake160_bin = CKB::Utils.hex_to_bin(script.args)
      type = [SHORT_FORMAT].pack("H*")
      code_hash_index = [code_hash_index].pack("H*")
      type + code_hash_index + blake160_bin
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(00) | single_arg
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_short_payload_singlesig_address
      ConvertAddress.encode(prefix, short_payload(CODE_HASH_INDEX_SINGLESIG), Bech32::Encoding::BECH32)
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(01) | multisig_arg
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_short_payload_multisig_address
      ConvertAddress.encode(prefix, short_payload(CODE_HASH_INDEX_MULTISIG_SIG), Bech32::Encoding::BECH32)
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(02) | args
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_short_payload_anyone_can_pay_address
      ConvertAddress.encode(prefix, short_payload(CODE_HASH_INDEX_ANYONE_CAN_PAY), Bech32::Encoding::BECH32)
    end

    # Generates full payload format address
    # payload = 0x02/0x04 | code_hash | args
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_full_payload_address
      case version
      when CKB::Address::Version::CKB2019
        format_type = CKB::ScriptHashType::TYPE == script.hash_type ? FULL_TYPE_FORMAT : FULL_DATA_FORMAT
        CKB::ConvertAddress.encode(prefix, first_version_full_payload(format_type), Bech32::Encoding::BECH32)
      when CKB::Address::Version::CKB2021
        # payload = 0x00 | code_hash | hash_type | args
        CKB::ConvertAddress.encode(prefix, current_version_full_payload(FULL_WITH_IDENTIFIER_FORMAT), Bech32::Encoding::BECH32M)
      else
        raise InvalidVersionError, "invalid address version"
      end
    end

    def first_version_full_payload(format_type)
      args = script.has_args? ? CKB::Utils.hex_to_bin(script.args) : ""
      [format_type].pack("H*") + CKB::Utils.hex_to_bin(script.code_hash) + args
    end

    def current_version_full_payload(format_type)
      args = script.has_args? ? CKB::Utils.hex_to_bin(script.args) : ""
      hash_type = [CKB::ScriptHashType::TYPES.index(script.hash_type)].pack("C")
      [format_type].pack("H*") + CKB::Utils.hex_to_bin(script.code_hash) + hash_type + args
    end

    class InvalidModeError < StandardError; end
    class InvalidVersionError < StandardError; end
  end
end
