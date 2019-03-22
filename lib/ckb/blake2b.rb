# frozen_string_literal: true

require "rbnacl"

module CKB
  class Blake2b
    DEFAULT_OPTIONS = {
      personal: "ckb-default-hash",
      digest_size: 32
    }.freeze

    def initialize(_opts = {})
      @blake2b = self.class.generate
    end

    # @param [String] string, not bin
    def update(message)
      @blake2b.update(message)
      @blake2b
    end

    alias << update

    def digest
      @blake2b.digest
    end

    def self.generate(_opts = {})
      ::RbNaCl::Hash::Blake2b.new(DEFAULT_OPTIONS.dup)
    end

    def self.digest(message)
      ::RbNaCl::Hash::Blake2b.digest(message, DEFAULT_OPTIONS.dup)
    end
  end
end
