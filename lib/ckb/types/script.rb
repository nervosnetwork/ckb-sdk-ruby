# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_accessor :code_hash, :args, :hash_type

      # @param code_hash [String]
      # @param args [String[]]
      def initialize(code_hash:, args:, hash_type: "Data")
        @code_hash = code_hash
        @args = args
        @hash_type = hash_type
      end

      # @return [Integer] Byte
      def calculate_bytesize
        bytesize = 1
        bytesize += Utils.hex_to_bin(@code_hash).bytesize if @code_hash
        (@args || []).map { |arg| Utils.hex_to_bin(arg).bytesize }.reduce(bytesize, &:+)
      end

      def to_h
        {
          code_hash: @code_hash,
          args: @args,
          hash_type: @hash_type
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          code_hash: hash[:code_hash],
          args: hash[:args],
          hash_type: hash[:hash_type]
        )
      end

      def to_hash(api)
        api.compute_script_hash(to_h)
      end

      def self.generate_lock(target_pubkey_blake160, secp_cell_type_hash, hash_type = "Type")
        new(
          code_hash: secp_cell_type_hash,
          args: [
            target_pubkey_blake160
          ],
          hash_type: hash_type
        )
      end
    end
  end
end
