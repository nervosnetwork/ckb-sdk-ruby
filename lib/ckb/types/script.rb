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

      # @return [Integer]
      def calculate_bytesize
        bytesize = (@args || []).map(&:bytesize).reduce(0, &:+)
        bytesize += Utils.hex_to_bin(@code_hash).bytesize if @code_hash
      end

      def to_h
        {
          code_hash: @code_hash,
          args: @args
        }
      end

      def self.from_h(hash)
        return if hash.nil?

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

      def self.generate_lock(target_pubkey_blake160, system_script_code_hash)
        new(
          code_hash: system_script_code_hash,
          args: [
            target_pubkey_blake160
          ]
        )
      end
    end
  end
end
