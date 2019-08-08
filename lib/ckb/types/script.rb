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

      def to_hash
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin(@code_hash) if @code_hash
        blake2b << case @hash_type
                   when "Data"
                     "\x0"
                   when "Type"
                     "\x1"
                   else
                     raise "Invalid hash type!"
                   end
        args = @args || []
        args.each do |arg|
          blake2b << Utils.hex_to_bin(arg)
        end
        blake2b.hexdigest
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
