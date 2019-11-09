# frozen_string_literal: true

module CKB
  class Address
    attr_reader :script, :prefix, :mode

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"
    DEFAULT_MODE = MODE::TESTNET
    TYPES = %w(01 02 04)
    CODE_HASH_INDEXES = %w(00 01)
    SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
    SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH = "0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8"

    # @param script [CKB::Types::Script]
    # @param mode [String]
    def initialize(script, mode: DEFAULT_MODE)
      @script = script
      @mode = mode
      @prefix = self.class.prefix(mode: mode)
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | code hash index(00) | pubkey blake160
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    def generate
      return generate_full_payload_address unless CKB::Types::Script::TYPE == script.hash_type && CKB::Utils.hex_to_bin(script.args).bytesize == 20

      if(SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH == script.code_hash)
        generate_short_payload_singlesig_address
      elsif SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH == script.code_hash
        generate_short_payload_multisig_address
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
        raise InvalidModeError.new("Invalid mode")
      end
    end

    private

    def short_payload(code_hash_index)
      blake160_bin = CKB::Utils.hex_to_bin(script.args)
      type = [TYPES[0]].pack("H*")
      code_hash_index = [code_hash_index].pack("H*")
      type + code_hash_index + blake160_bin
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(00) | single_arg
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_short_payload_singlesig_address
      ConvertAddress.encode(prefix, short_payload(CODE_HASH_INDEXES[0]))
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(01) | multisig_arg
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_short_payload_multisig_address
      ConvertAddress.encode(prefix, short_payload(CODE_HASH_INDEXES[1]))
    end

    # Generates full payload format address
    # payload = 0x02/0x04 | code_hash | args
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    #
    # @return [String]
    def generate_full_payload_address
      format_type = CKB::Types::Script::TYPE == script.hash_type ? TYPES[2] : TYPES[1]
      payload = [format_type].pack("H*") + CKB::Utils.hex_to_bin(script.code_hash) + CKB::Utils.hex_to_bin(script.args)

      CKB::ConvertAddress.encode(prefix, payload)
    end

    class InvalidModeError < StandardError; end
  end
end
