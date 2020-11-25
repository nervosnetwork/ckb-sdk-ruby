# frozen_string_literal: true

module CKB
  class AddressParser
    attr_reader :address

    # @param address [string]
    def initialize(address)
      @address = address
    end

    def parse
      decoded_prefix, data = ConvertAddress.decode(address)
      format_type = data[0].unpack("H*").first

      case format_type
      when Address::SHORT_FORMAT
        parse_short_payload_address(decoded_prefix, data)
      when Address::FULL_DATA_FORMAT, Address::FULL_TYPE_FORMAT
        parse_full_payload_address(decoded_prefix, data)
      else
        raise InvalidFormatTypeError, "Invalid format type"
      end
    end

    private

    def parse_address_type(format_type, code_hash_index = nil)
      return "FULL" if Address::SHORT_FORMAT != format_type

      case code_hash_index
      when Address::CODE_HASH_INDEX_SINGLESIG
        "SHORTSINGLESIG"
      when Address::CODE_HASH_INDEX_MULTISIG_SIG
        "SHORTMULTISIG"
      when Address::CODE_HASH_INDEX_ANYONE_CAN_PAY
        "SHORTANYONECANPAY"
      else
        raise InvalidCodeHashIndexError, "Invalid code hash index"
      end
    end

    def parse_short_payload_address(decoded_prefix, data)
      format_type = data[0].unpack("H*").first
      code_hash_index = data[1].unpack("H*").first
      mode = parse_mode(decoded_prefix)
      code_hash = parse_code_hash(code_hash_index, mode)
      args = CKB::Utils.bin_to_hex(data.slice(2..-1))
      if code_hash_index != CKB::Address::CODE_HASH_INDEX_ANYONE_CAN_PAY && CKB::Utils.hex_to_bin(args).bytesize != 20
        raise InvalidArgSizeError, "Short payload format address args bytesize must equal to 20"
      end

      OpenStruct.new(mode: mode, script: CKB::Types::Script.new(code_hash: code_hash, args: args, hash_type: CKB::ScriptHashType::TYPE), address_type: parse_address_type(format_type, code_hash_index))
    end

    def parse_full_payload_address(decoded_prefix, data)
      format_type = data[0].unpack("H*").first
      mode = parse_mode(decoded_prefix)
      hash_type = parse_hash_type(format_type)
      offset = 1
      code_hash_size = 32
      raise InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32" if data[1..-1].size < code_hash_size

      code_hash = "0x#{data.slice(1..code_hash_size).unpack('H*').first}"
      offset += code_hash_size
      args = CKB::Utils.bin_to_hex(data[offset..-1])

      OpenStruct.new(mode: mode, script: CKB::Types::Script.new(code_hash: code_hash, args: args, hash_type: hash_type), address_type: parse_address_type(format_type))
    end

    def parse_hash_type(format_type)
      case format_type
      when Address::FULL_DATA_FORMAT
        CKB::ScriptHashType::DATA
      when Address::FULL_TYPE_FORMAT
        CKB::ScriptHashType::TYPE
      else
        raise InvalidFormatTypeError, "Invalid format type"
      end
    end

    def parse_code_hash(code_hash_index, mode)
      case code_hash_index
      when Address::CODE_HASH_INDEX_SINGLESIG
        SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
      when Address::CODE_HASH_INDEX_MULTISIG_SIG
        SystemCodeHash::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH
      when Address::CODE_HASH_INDEX_ANYONE_CAN_PAY
        if mode == CKB::MODE::TESTNET
          SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON
        else
          SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA
        end
      else
        raise InvalidCodeHashIndexError, "Invalid code hash index"
      end
    end

    def parse_mode(decoded_prefix)
      case decoded_prefix
      when Address::PREFIX_TESTNET
        MODE::TESTNET
      when Address::PREFIX_MAINNET
        MODE::MAINNET
      else
        raise InvalidPrefixError, "Invalid prefix"
      end
    end

    class InvalidFormatTypeError < StandardError; end
    class InvalidArgSizeError < StandardError; end
    class InvalidPrefixError < StandardError; end
    class InvalidCodeHashIndexError < StandardError; end
    class InvalidCodeHashSizeError < StandardError; end
  end
end
