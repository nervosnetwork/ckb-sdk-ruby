# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_accessor :code_hash, :args, :hash_type

      # @param code_hash [String]
      # @param args [String]
      # @param hash_type [String] data/type
      def initialize(code_hash:, args:, hash_type: "data")
        @code_hash = code_hash
        @args = args
        @hash_type = hash_type
        validate_code_hash!
        validate_args!
        validate_hash_type!
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

      def validate_code_hash!
        raise EmptyCodeHashError, "CodeHash cannot be empty" unless has_code_hash?

        raise InvalidHexStringError, "CodeHash is an invalid hex string" unless CKB::Utils.valid_hex_string?(code_hash)

        if CKB::Utils.hex_to_bin(code_hash).size != 32
          raise InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32"
        end
      end

      def validate_args!
        raise InvalidHexStringError, "Args is an invalid hex string" if has_args? && !CKB::Utils.valid_hex_string?(args)
      end

      def has_code_hash?
        !code_hash.nil? && !code_hash.empty?
      end

      def has_args?
        !args.nil? && !args.empty?
      end

      def validate_hash_type!
        raise InvalidHashTypeError, "Invalid hash type error" unless CKB::ScriptHashType::TYPES.include?(hash_type)
      end

      class EmptyCodeHashError < StandardError; end
      class InvalidHexStringError < StandardError; end
      class InvalidHashTypeError < StandardError; end
      class InvalidCodeHashSizeError < StandardError; end
    end
  end
end
