# frozen_string_literal: true

require "securerandom"
require "rbsecp256k1"

module CKB
  class Key
    attr_reader :privkey, :pubkey

    # @param privkey [String] hex string
    def initialize(privkey)
      raise ArgumentError, "invalid privkey!" unless privkey.instance_of?(String) && privkey.size == 66

      raise ArgumentError, "invalid hex string!" unless CKB::Utils.valid_hex_string?(privkey)

      @privkey = privkey
      @privkey_bin = Utils.hex_to_bin(privkey)
      @context = Secp256k1::Context.create

      begin
        @key_pair = @context.key_pair_from_private_key(@privkey_bin)
        @pubkey = Utils.bin_to_hex @key_pair.public_key.compressed
      rescue Secp256k1::Error => e
        if e.message == 'invalid private key data'
          raise ArgumentError, "invalid privkey!"
        else
          raise e
        end
      end
    end

    # @param data [String] hex string
    # @return [String] signature in hex string
    def sign(data)
      signature_bin = @context.sign(@key_pair.private_key, Utils.hex_to_bin(data))
      Utils.bin_to_hex(signature_bin.der_encoded)
    end

    # @param data [String] hex string
    # @return [String] signature in hex string
    def sign_recoverable(data)
      signature = @context.sign_recoverable(@key_pair.private_key, Utils.hex_to_bin(data))
      signature_bin, recid = signature.compact
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
      context = Secp256k1::Context.create
      privkey_bin = Utils.hex_to_bin(privkey)
      key_pair = context.key_pair_from_private_key(privkey_bin)
      Utils.bin_to_hex(key_pair.public_key.compressed)
    end

    def self.blake160(pubkey)
      pubkey = pubkey[2..-1] if pubkey.start_with?("0x")
      pubkey_bin = [pubkey].pack("H*")
      hash_bin = CKB::Blake2b.digest(pubkey_bin)
      Utils.bin_to_hex(hash_bin[0...20])
    end
  end
end
