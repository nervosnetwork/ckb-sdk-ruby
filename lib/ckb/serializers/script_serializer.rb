# frozen_string_literal: true

module CKB
  module Serializers
    class ScriptSerializer
      include TableSerializer

      # @param script [CKB::Types::Script]
      def initialize(script)
        @code_hash_serializer = CodeHashSerializer.new(script.code_hash)
        @hash_type_serializer = HashTypeSerializer.new(script.hash_type)
        args = init_args(script)
        @args_serializer = FixVecSerializer.new(args.scan(/../), ByteSerializer)
        @items_count = 3
      end

      private

      def init_args(script)
        args = script.args
        if args
          args.start_with?("0x") ? args[2..-1] : args
        else
          ""
        end
      end

      attr_reader :code_hash_serializer, :hash_type_serializer, :args_serializer, :items_count

      def body
        code_hash_layout + hash_type_layout + args_layout
      end

      def offsets
        script_offset0 = (items_count + 1) * UINT32_CAPACITY
        script_offset1 = script_offset0 + BYTE32_CAPACITY
        script_offset2 = script_offset1 + SCRIPT_HASH_TYPE_CAPACITY

        [script_offset0, script_offset1, script_offset2]
      end

      def code_hash_layout
        code_hash_serializer.serialize[2..-1]
      end

      def hash_type_layout
        hash_type_serializer.serialize[2..-1]
      end

      def args_layout
        args_serializer.serialize[2..-1]
      end
    end
  end
end
