# frozen_string_literal: true

module CKB
  class Address
    attr_reader :blake160 # pubkey hash
    alias pubkey_hash blake160

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"

    DEFAULT_MODE = MODE::TESTNET

    TYPES = %w(01 02 04)
    CODE_HASH_INDEXES = %w(00 01)

    def initialize(blake160, mode: DEFAULT_MODE)
      @mode = mode
      @blake160 = blake160
      @prefix = self.class.prefix(mode: mode)
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | code hash index(00) | pubkey blake160
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    def generate
      blake160_bin = [blake160[2..-1]].pack("H*")
      type = [TYPES[0]].pack("H*")
      code_hash_index = [CODE_HASH_INDEXES[0]].pack("H*")
      payload = type + code_hash_index + blake160_bin
      ConvertAddress.encode(@prefix, payload)
    end

    # Generates short payload format address
    # payload = type(01) | code hash index(01) | pubkey hash160
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    # @param [String] hash160
    # @return [String]
    def generate_short_payload_hash160_address(hash160)
      hash160_bin = [hash160[2..-1]].pack("H*")
      type = [TYPES[0]].pack("H*")
      code_hash_index = [CODE_HASH_INDEXES[1]].pack("H*")
      payload = type + code_hash_index + hash160_bin
      ConvertAddress.encode(@prefix, payload)
    end

    # Generates full payload format address
    # payload = 0x02/0x04 | code_hash | len(arg[0]) | arg[0] | ...
    # see https://github.com/nervosnetwork/rfcs/blob/master/rfcs/0021-ckb-address-format/0021-ckb-address-format.md for more info.
    # @param [String | Integer]  format_type
    # @param [String]  code_hash
    # @param [String[]]  args
    # @return [String]
    def generate_full_payload_address(format_type, code_hash, args)
      format_type = Utils.to_hex(format_type)[2..-1].rjust(2, '0')
      raise InvalidFormatTypeError.new("Invalid format type") unless TYPES[1..-1].include?(format_type)
      raise InvalidArgsTypeError.new("Args should be an array") unless args.is_a?(Array)

      payload = [format_type].pack("H*") + CKB::Utils.hex_to_bin(code_hash)
      args.each do |arg|
        arg_bytes = CKB::Utils.hex_to_bin(arg)
        arg_len = arg_bytes.bytesize
        if arg_len > 256
          raise InvalidArgSizeError.new("The maximum size of arg is 256")
        else
          payload += [arg_len].pack("C") + arg_bytes
        end
      end

      CKB::ConvertAddress.encode(@prefix, payload)
    end

    alias to_s generate

    # Parse address into lock assuming default lock script is used
    def parse(address)
      self.class.parse(address, mode: @mode)
    end

    def parse_short_payload_hash160_address(address)
      self.class.parse_short_payload_hash160_address(address, mode: @mode)
    end

    def parse_full_payload_address(address)
      self.class.parse_full_payload_address(address, mode: @mode)
    end

    def self.parse_short_payload_hash160_address(address, mode: DEFAULT_MODE)
      decoded_prefix, data = ConvertAddress.decode(address)

      raise InvalidPrefixError.new("Invalid prefix") if decoded_prefix != prefix(mode: mode)
      raise InvalidFormatTypeError.new("Invalid format type") if data[0] != [TYPES[0]].pack("H*")
      raise InvalidCodeHashIndexError.new("Invalid code hash index") if data[1] != [CODE_HASH_INDEXES[1]].pack("H*")

      CKB::Utils.bin_to_hex(data.slice(2..-1))
    end

    def self.parse_full_payload_address(address, mode: DEFAULT_MODE)
      decoded_prefix, data = ConvertAddress.decode(address)
      format_type = data[0].unpack("H*").first

      raise InvalidPrefixError.new("Invalid prefix") if decoded_prefix != prefix(mode: mode)
      raise InvalidFormatTypeError.new("Invalid format type") unless TYPES[1..-1].include?(format_type)

      offset = 1
      code_hash_size = 32
      code_hash = "0x#{data.slice(offset..code_hash_size).unpack("H*").first}"
      offset += 32
      data_size = data.bytesize
      args = []
      while offset < data_size
        arg_len = data[offset].unpack("C").first.to_i
        offset += 1
        arg = data[offset...offset + arg_len]
        args << arg
        offset += arg_len
      end

      [format_type, code_hash, args.map { |item| CKB::Utils.bin_to_hex(item) }]
    end

    def self.parse(address, mode: DEFAULT_MODE)
      decoded_prefix, data = ConvertAddress.decode(address)

      raise InvalidPrefixError.new("Invalid prefix") if decoded_prefix != prefix(mode: mode)
      raise InvalidFormatTypeError.new("Invalid format type") if data[0] != [TYPES[0]].pack("H*")
      raise InvalidCodeHashIndexError.new("Invalid code hash index") if data[1] != [CODE_HASH_INDEXES[0]].pack("H*")

      CKB::Utils.bin_to_hex(data.slice(2..-1))
    end

    def self.blake160(pubkey)
      pubkey = pubkey[2..-1] if pubkey.start_with?("0x")
      pubkey_bin = [pubkey].pack("H*")
      hash_bin = CKB::Blake2b.digest(pubkey_bin)
      Utils.bin_to_hex(hash_bin[0...20])
    end

    def self.hash160(pubkey)
      pubkey = pubkey[2..-1] if pubkey.start_with?("0x")
      pub_key_sha256 = Digest::SHA256.hexdigest(pubkey)

      "0x#{Digest::RMD160.hexdigest(pub_key_sha256)}"
    end

    def self.from_pubkey(pubkey, mode: DEFAULT_MODE)
      new(blake160(pubkey), mode: mode)
    end

    def self.prefix(mode: DEFAULT_MODE)
      case mode
      when MODE::TESTNET
        PREFIX_TESTNET
      when MODE::MAINNET
        PREFIX_MAINNET
      end
    end

    class InvalidFormatTypeError < StandardError; end
    class InvalidArgsTypeError < StandardError; end
    class InvalidArgSizeError < StandardError; end
    class InvalidPrefixError < StandardError; end
    class InvalidCodeHashIndexError < StandardError; end
  end
end
