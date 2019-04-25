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

    def self.json_script_to_type_hash(script)
      blake2b = CKB::Blake2b.new
      blake2b << hex_to_bin(script[:code_hash]) if script[:code_hash]
      args = script[:args] || []
      args.each do |arg|
        blake2b << hex_to_bin(arg)
      end
      bin_to_hex(blake2b.digest)
    end

    def self.generate_lock(target_pubkey_blake160, system_script_cell_hash)
      target_pubkey_blake160_bin = CKB::Utils.hex_to_bin(target_pubkey_blake160)
      {
        code_hash: system_script_cell_hash,
        args: [
          # There are 2 conversions from binary to hex string here:
          # 1. The inner unpack1 is required since the deployed lock script
          # now accepts a hex string version of the public key hash so we can
          # treat it as a null-terminated string in C for ease of processing.
          # So even though the inner unpack1 already converts the public key
          # hash binary to a hex string format, we should still see it as a
          # binary from the SDK point of view.
          # 2. The outer bin_to_hex then converts the binary (in SDK
          # point of view) to a hex string required by CKB RPC.
          CKB::Utils.bin_to_hex(target_pubkey_blake160_bin.unpack1("H*"))
        ]
      }
    end
  end
end
