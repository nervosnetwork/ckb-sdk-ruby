# frozen_string_literal: true

module CKB
  class Key
    attr_reader :privkey, :pubkey, :address

    # @param privkey [String] hex string
    def initialize(privkey)
      raise ArgumentError, "invalid privkey!" unless privkey.instance_of?(String) && privkey.size == 66

      raise ArgumentError, "invalid hex string!" unless CKB::Utils.valid_hex_string?(privkey)

      @privkey = privkey

      @pubkey = self.class.pubkey(@privkey)

      @address = Address.from_pubkey(pubkey)
    end

    def sign(hex_data)
      privkey_bin = Utils.hex_to_bin(privkey)
      secp_key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
      signature_bin = secp_key.ecdsa_serialize(
        secp_key.ecdsa_sign(Utils.hex_to_bin(hex_data), raw: true)
      )
      Utils.bin_to_hex(signature_bin)
    end

    def sign_compact(hex_data)
      privkey_bin = Utils.hex_to_bin(privkey)
      secp_key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
      signature_bin = secp_key.ecdsa_serialize_compact(
        secp_key.ecdsa_sign(Utils.hex_to_bin(hex_data), raw: true)
      )
      Utils.bin_to_hex(signature_bin)
    end

    def self.random_private_key
      CKB::Utils.bin_to_hex(SecureRandom.bytes(32))
    end

    def self.pubkey(privkey)
      privkey_bin = [privkey[2..-1]].pack("H*")
      pubkey_bin = Secp256k1::PrivateKey.new(privkey: privkey_bin).pubkey.serialize
      Utils.bin_to_hex(pubkey_bin)
    end
  end
end
