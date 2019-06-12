# frozen_string_literal: true

require "securerandom"
require "secp256k1"

module CKB
  class Key
    attr_reader :privkey, :pubkey, :address

    # @param privkey [String] hex string
    def initialize(privkey)
      raise ArgumentError, "invalid privkey!" unless privkey.instance_of?(String) && privkey.size == 66

      raise ArgumentError, "invalid hex string!" unless CKB::Utils.valid_hex_string?(privkey)

      @privkey = privkey

      begin
        @pubkey = self.class.pubkey(@privkey)
      rescue Secp256k1::AssertError
        raise ArgumentError, "invalid privkey!"
      end

      @address = Address.from_pubkey(pubkey)
    end

    # @param data [String] hex string
    # @return [String] signature in hex string
    def sign(data)
      privkey_bin = Utils.hex_to_bin(privkey)
      secp_key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
      signature_bin, recid = secp_key.ecdsa_recoverable_serialize(
        secp_key.ecdsa_sign_recoverable(Utils.hex_to_bin(data), raw: true)
      )
      Utils.bin_to_hex(signature_bin + [recid].pack("C*"))
    end

    def self.random_private_key
      candidate = CKB::Utils.bin_to_hex(SecureRandom.random_bytes(32))
      new(candidate)
      candidate
    rescue ArgumentError
      retry
    end

    def self.pubkey(privkey)
      privkey_bin = [privkey[2..-1]].pack("H*")
      pubkey_bin = Secp256k1::PrivateKey.new(privkey: privkey_bin).pubkey.serialize
      Utils.bin_to_hex(pubkey_bin)
    end
  end
end
