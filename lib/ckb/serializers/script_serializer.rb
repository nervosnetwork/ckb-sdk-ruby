# frozen_string_literal: true

module CKB
  module Serializers
    class ScriptSerializer
      attr_reader :code_hash, :args, :hash_type, :args_count

      # @param script [CKB::Types::Script]
      def initialize(script)
        @args = script.args
        @code_hash = script.code_hash
        @hash_type = script.hash_type
        @args_count = args.count
      end

      def serialize
        layout
      end

      private

      def byte32_capacity
        32
      end

      def uint32_capacity
        4
      end

      def script_hash_type_capacity
        1
      end

      def arg_layout(arg)
        arg_body = arg.delete_prefix("0x")
        items_count = [arg_body].pack("H*").bytesize
        items_count_hex = [items_count].pack("V").unpack1("H*")
        arg_header = items_count_hex
        arg_header + arg_body
      end

      def arg_layouts
        return "" if args_count == 0

        args.map(&method(:arg_layout)).join("")
      end

      def args_layout
        if args_count == 0
          args_layout = [uint32_capacity].pack("V").unpack1("H*")
        else
          args_body = arg_layouts

          args_body_capacity = [args_body].pack("H*").bytesize
          args_full_length = (args_count + 1) * uint32_capacity + args_body_capacity
          args_full_length_hex = [args_full_length].pack("V").unpack1("H*")
          args_offset0 = (args_count + 1) * uint32_capacity
          args_offsets = [args_offset0]
          args.each.with_index(1) do |_arg, index|
            break if args[index].nil?
            args_offsets << (args_offset0 += [args[index - 1].delete_prefix("0x")].pack("H*").bytesize)
          end

          args_offsets_hex = args_offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
          args_header = args_full_length_hex + args_offsets_hex
          args_layout = args_header + args_body
        end

        args_layout
      end

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex(body) + offsets_hex
      end

      def body
        code_hash.delete_prefix("0x") + (hash_type == "data" ? "00" : "01") + args_layout
      end

      def offsets
        script_offset0 = 4 * uint32_capacity
        script_offset1 = script_offset0 + byte32_capacity
        script_offset2 = script_offset1 + script_hash_type_capacity

        [script_offset0, script_offset1, script_offset2]
      end

      def full_length_hex(script_body)
        script_body_capacity = [script_body].pack("H*").bytesize
        script_full_length = 4 * uint32_capacity + script_body_capacity
        [script_full_length].pack("V").unpack1("H*")
      end
    end
  end
end