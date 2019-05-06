# frozen_string_literal: true

require "secp256k1"

module CKB
  module Utils
    def self.bin_to_hex(bin)
      "0x#{bin.unpack1('H*')}"
    end

    def self.valid_hex_string?(hex)
      hex.start_with?("0x") && hex.length.even?
    end

    def self.hex_to_bin(hex)
      raise ArgumentError, "invalid hex string!" unless valid_hex_string?(hex)

      [hex[2..-1]].pack("H*")
    end
  end
end
