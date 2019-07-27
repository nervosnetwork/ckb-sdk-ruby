# frozen_string_literal: true

module CKB
  class Address
    attr_reader :blake160 # pubkey hash
    alias pubkey_hash blake160

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"

    DEFAULT_MODE = MODE::TESTNET

    TYPE = "01"
    CODE_HASH_INDEX = "00"

    def initialize(blake160, mode: DEFAULT_MODE)
      @mode = mode
      @blake160 = blake160
      @prefix = self.class.prefix(mode: mode)
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | code hash index(00) | pubkey blake160
    # see https://github.com/nervosnetwork/ckb/wiki/Common-Address-Format for more info.
    def generate
      blake160_bin = [blake160[2..-1]].pack("H*")
      type = [TYPE].pack("H*")
      code_hash_index = [CODE_HASH_INDEX].pack("H*")
      payload = type + code_hash_index + blake160_bin
      ConvertAddress.encode(@prefix, payload)
    end

    alias to_s generate

    # Parse address into lock assuming default lock script is used
    def parse(address)
      self.class.parse(address, mode: @mode)
    end

    def self.parse(address, mode: DEFAULT_MODE)
      decoded_prefix, data = ConvertAddress.decode(address)

      raise "Invalid prefix" if decoded_prefix != prefix(mode: mode)

      raise "Invalid type/code hash index" if data.slice(0..1) != [TYPE + CODE_HASH_INDEX].pack("H*")

      CKB::Utils.bin_to_hex(data.slice(2..-1))
    end

    def self.blake160(pubkey)
      pubkey = pubkey[2..-1] if pubkey.start_with?("0x")
      pubkey_bin = [pubkey].pack("H*")
      hash_bin = CKB::Blake2b.digest(pubkey_bin)
      Utils.bin_to_hex(hash_bin[0...20])
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
  end
end
