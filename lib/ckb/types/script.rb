# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_reader :code_hash, :args

      # @param code_hash [String]
      # @param args [String[]]
      def initialize(code_hash:, args:)
        @code_hash = code_hash
        @args = args
      end

      def to_h
        {
          code_hash: @code_hash,
          args: @args
        }
      end

      def self.from_h(hash)
        new(
          code_hash: hash[:code_hash],
          args: hash[:args]
        )
      end

      def to_hash
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin(@code_hash) if @code_hash
        args = @args || []
        args.each do |arg|
          blake2b << Utils.hex_to_bin(arg)
        end
        Utils.bin_to_hex(blake2b.digest)
      end

      def self.generate_lock(target_pubkey_blake160, system_script_cell_hash)
        target_pubkey_blake160_bin = CKB::Utils.hex_to_bin(target_pubkey_blake160)
        new(
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
        )
      end
    end
  end
end
