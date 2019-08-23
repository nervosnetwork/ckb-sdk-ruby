# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_accessor :code_hash, :args, :hash_type

      # @param code_hash [String]
      # @param args [String[]]
      def initialize(code_hash:, args:, hash_type: "data")
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
        args_count = args.count
        if args_count == 0
          args_layout = [4].pack("V").unpack1("H*")
        else
          arg_layouts = args.map do |arg|
            arg_body = arg.delete_prefix("0x")
            items_count = [arg_body].pack("H*").bytesize
            items_count_hex = [items_count].pack("V").unpack1("H*")
            arg_header = items_count_hex
            arg_layout = arg_header + arg_body
            arg_layout
          end.join("")
          args_body = arg_layouts

          args_body_capacity = [args_body].pack("H*").bytesize
          args_full_length = 4 + args_count * 4 + args_body_capacity
          args_full_length_hex = [args_full_length].pack("V").unpack1("H*")
          args_offset0 = (args_count + 1) * 4
          args_offsets = [args_offset0]
          args.each.with_index(1) do |_arg, index|
            break if args[index].nil?
            args_offsets << (args_offset0 += [args[index-1].delete_prefix("0x")].pack("H*").bytesize)
          end

          args_offsets_hex = args_offsets.map { |offset| [offset].pack("V").unpack1("H*") }.join("")
          args_header = args_full_length_hex + args_offsets_hex
          args_layout = args_header + args_body
        end

        script_body = code_hash.delete_prefix("0x") + (hash_type == "data" ? "00" : "01") + args_layout
        script_body_capacity = [script_body].pack("H*").bytesize
        script_full_length = 4 + 3 * 4 + script_body_capacity
        script_full_length_hex = [script_full_length].pack("V").unpack1("H*")
        script_offset0 = 4 * 4
        script_offset1 = script_offset0 + 32
        script_offset2 = script_offset1 + 1

        script_offsets = [script_offset0, script_offset1, script_offset2]
        script_offsets_hex = script_offsets.map { |offset| [offset].pack("V").unpack1("H*") }.join("")
        script_header = script_full_length_hex + script_offsets_hex
        script_layout = script_header + script_body
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin("0x#{script_layout}")

        blake2b.hexdigest
      end

      def self.generate_lock(target_pubkey_blake160, secp_cell_type_hash, hash_type = "type")
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
