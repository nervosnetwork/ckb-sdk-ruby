# frozen_string_literal: true

module CKB
  class Address
    attr_reader :pubkey

    MODE_TESTNET = "testnet"
    MODE_MAINNET = "mainnet"
    MODE_CUSTOM = "custom"

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"

    def initialize(pubkey, mode: MODE_TESTNET)
      @pubkey = pubkey
      @prefix = if mode == MODE_TESTNET
                  PREFIX_TESTNET
                elsif mode == MODE_MAINNET
                  PREFIX_MAINNET
                end
    end

    def blake160
      @blake160 ||= self.class.blake160(@pubkey)
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | bin-idx("P2PH" => "50/32/50/48") | pubkey blake160
    # see https://github.com/nervosnetwork/ckb/wiki/Common-Address-Format for more info.
    def generate
      blake160_bin = [blake160[2..-1]].pack("H*")
      payload = ["0150325048"].pack("H*") + blake160_bin
      ConvertAddress.encode(@prefix, payload)
    end

    alias to_s generate

    # Parse address into lock assuming default lock script is used
    def parse(address)
      decoded_prefix, data = ConvertAddress.decode(address)
      raise "Invalid prefix" if decoded_prefix != @prefix

      raise "Invalid type/bin-idx" if data.slice(0..4) != ["0150325048"].pack("H*")

      CKB::Utils.bin_to_hex(data.slice(5..-1))
    end

    def self.blake160(pubkey)
      pubkey_bin = [pubkey[2..-1]].pack("H*")
      hash_bin = CKB::Blake2b.digest(pubkey_bin)
      Utils.bin_to_hex(hash_bin[0...20])
    end
  end
end
