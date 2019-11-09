# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_accessor :code_hash, :args, :hash_type
      HASH_TYPES = [TYPE = "type", DATA = "data"]
      # @param code_hash [String]
      # @param args [String]
      # @param hash_type [String] data/type
      def initialize(code_hash:, args:, hash_type: "data")
        @code_hash = code_hash
        @args = args
        @hash_type = hash_type

        raise InvalidHashTypeError.new("Invalid hash type error") unless HASH_TYPES.include?(hash_type)
      end

      # @return [Integer] Byte
      def calculate_bytesize
        bytesize = 1
        bytesize += Utils.hex_to_bin(@code_hash).bytesize if @code_hash
        bytesize += Utils.hex_to_bin(args).bytesize if args

        bytesize
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

      def compute_hash
        script_serializer = CKB::Serializers::ScriptSerializer.new(self)
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin(script_serializer.serialize)

        blake2b.hexdigest
      end

      def self.generate_lock(target_pubkey_blake160, secp_cell_type_hash, hash_type = "type")
        new(
          code_hash: secp_cell_type_hash,
          args: target_pubkey_blake160,
          hash_type: hash_type
        )
      end

      class InvalidHashTypeError < StandardError; end
    end
  end
end
