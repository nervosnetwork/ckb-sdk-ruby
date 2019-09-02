# frozen_string_literal: true

module CKB
  module Serializers
    class ScriptSerializer
      # @param script [CKB::Types::Script]
      def initialize(script)
        @args_serializer = ArgsSerializer.new(script.args)
        @code_hash = script.code_hash
        @hash_type = script.hash_type
        @items_count = 3
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :code_hash, :args, :hash_type, :items_count, :args_serializer

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        code_hash.delete_prefix("0x") + (hash_type == "data" ? "00" : "01") + args_serializer.serialize
      end

      def offsets
        script_offset0 = (items_count + 1) * uint32_capacity
        script_offset1 = script_offset0 + byte32_capacity
        script_offset2 = script_offset1 + script_hash_type_capacity

        [script_offset0, script_offset1, script_offset2]
      end

      def full_length_hex
        script_full_length = (items_count + 1) * uint32_capacity + body_capacity
        [script_full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def byte32_capacity
        32
      end

      def uint32_capacity
        4
      end

      def script_hash_type_capacity
        1
      end
    end
  end
end