# frozen_string_literal: true

module CKB
  class Address
    attr_reader :blake160 # pubkey hash
    alias pubkey_hash blake160

    PREFIX_MAINNET = "ckb"
    PREFIX_TESTNET = "ckt"

    def initialize(blake160, mode: MODE::TESTNET)
      @blake160 = blake160
      @prefix = if mode == MODE::TESTNET
                  PREFIX_TESTNET
                elsif mode == MODE::MAINNET
                  PREFIX_MAINNET
                end
    end

    # Generates address assuming default lock script is used
    # payload = type(01) | bin-idx("P2PH" => "50/32/50/48") | pubkey blake160
    # see https://github.com/nervosnetwork/ckb/wiki/Common-Address-Format for more info.
    def generate
      blake160_bin = [blake160[2..-1]].pack("H*")
      type = ["01"].pack("H*")
      bin_idx = ["P2PH".each_char.map { |c| c.ord.to_s(16) }.join].pack("H*")
      payload = type + bin_idx + blake160_bin
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

    def self.from_pubkey(pubkey, mode: MODE::TESTNET)
      new(blake160(pubkey), mode: mode)
    end
  end
end
