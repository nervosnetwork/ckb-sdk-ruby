# frozen_string_literal: true

require "rbnacl"

module CKB
  class Blake2b
    DEFAULT_OPTIONS = {
      personal: "ckb-default-hash",
      digest_size: 32
    }.freeze

    def initialize
      @blake2b = self.class.generate
    end

    # @param [String] binary message
    def update(message)
      @blake2b.update(message)
      self
    end

    alias << update

    def digest
      @blake2b.digest
    end

    def hexdigest
      Utils.bin_to_hex(digest)
    end

    def self.generate
      ::RbNaCl::Hash::Blake2b.new(DEFAULT_OPTIONS.dup)
    end

    def self.digest(message)
      ::RbNaCl::Hash::Blake2b.digest(message, DEFAULT_OPTIONS.dup)
    end

    def self.hexdigest(message)
      Utils.bin_to_hex(
        digest(message)
      )
    end
  end
end
