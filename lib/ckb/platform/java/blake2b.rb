# frozen_string_literal: true

java_import org.bouncycastle.crypto.digests.Blake2bDigest

module CKB
  class Blake2b
    DEFAULT_OPTIONS = {
      personal: "ckb-default-hash".to_java_bytes,
      digest_size: 32
    }.freeze

    def initialize
      @blake2b = self.class.generate
    end

    # @param [String] binary message
    def update(message)
      java_bytes = message.to_java_bytes
      @blake2b.update(java_bytes, 0, java_bytes.size)
      self
    end

    alias << update

    def digest
      out = Java::byte[32].new
      @blake2b.do_final(out, 0)
      String.from_java_bytes(out)
    end

    def hexdigest
      Utils.bin_to_hex(digest)
    end

    def self.generate(_opts = {})
      # Blake2bDigest(byte[] _key, int _digestLength, byte[] _salt, byte[] _personalization)
      Blake2bDigest.new(
        nil,
        DEFAULT_OPTIONS[:digest_size],
        nil,
        DEFAULT_OPTIONS[:personal]
      )
    end

    def self.digest(message)
      blake2b = new
      blake2b.update(message)
      blake2b.digest
    end

    def self.hexdigest(message)
      Utils.bin_to_hex(
        self.digest(message)
      )
    end
  end
end
