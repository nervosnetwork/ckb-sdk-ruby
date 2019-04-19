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

      @address = Address.new(pubkey)
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
