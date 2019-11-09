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
      when "01"
        parse_short_payload_address(decoded_prefix, data)
      when "02", "04"
        parse_full_payload_address(decoded_prefix, data)
      else
        raise InvalidFormatTypeError.new("Invalid format type")
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
      else
        raise InvalidCodeHashIndexError.new("Invalid code hash index")
      end
    end

    def parse_short_payload_address(decoded_prefix, data)
      format_type = data[0].unpack("H*").first
      code_hash_index = data[1].unpack("H*").first
      mode = parse_mode(decoded_prefix)
      code_hash = parse_code_hash(code_hash_index)
      args = CKB::Utils.bin_to_hex(data.slice(2..-1))
      raise InvalidArgSizeError.new("Short payload format address args bytesize must equal to 20") if CKB::Utils.hex_to_bin(args).bytesize != 20

      OpenStruct.new(mode: mode, script: CKB::Types::Script.new(code_hash: code_hash, args: args, hash_type: CKB::ScriptHashType::TYPE), address_type: parse_address_type(format_type, code_hash_index))
    end

    def parse_full_payload_address(decoded_prefix, data)
      format_type = data[0].unpack("H*").first
      mode = parse_mode(decoded_prefix)
      hash_type = parse_hash_type(format_type)
      offset = 1
      code_hash_size = 32
      code_hash = "0x#{data.slice(1..code_hash_size).unpack("H*").first}"
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
        raise InvalidFormatTypeError.new("Invalid format type")
      end
    end

    def parse_code_hash(code_hash_index)
      case code_hash_index
      when Address::CODE_HASH_INDEX_SINGLESIG
        SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH
      when Address::CODE_HASH_INDEX_MULTISIG_SIG
        SystemCodeHash::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH
      else
        raise InvalidCodeHashIndexError.new("Invalid code hash index")
      end
    end

    def parse_mode(decoded_prefix)
      case decoded_prefix
      when Address::PREFIX_TESTNET
        MODE::TESTNET
      when Address::PREFIX_MAINNET
        MODE::MAINNET
      else
        raise InvalidPrefixError.new("Invalid prefix")
      end
    end

    class InvalidFormatTypeError < StandardError; end
    class InvalidArgSizeError < StandardError; end
    class InvalidPrefixError < StandardError; end
    class InvalidCodeHashIndexError < StandardError; end
  end
end
