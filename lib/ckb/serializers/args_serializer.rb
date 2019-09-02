# frozen_string_literal: true

module CKB
  module Serializers
    class ArgsSerializer
      # @param args [String[]]
      def initialize(args)
        @args = args
        @items_count = args.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :args, :items_count

      def layout
        if items_count == 0
          [uint32_capacity].pack("V").unpack1("H*")
        else
          header + body
        end
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        arg_layouts
      end

      def out_point_layout
        out_point_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offsets = [offset0]
        args.each.with_index(1) do |_arg, index|
          break if args[index].nil?

          offsets << offset0 += ArgSerializer.new(args[index - 1]).capacity
        end

        offsets
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [arg_layouts].pack("H*").bytesize
      end

      def arg_layouts
        return "" if items_count == 0

        args.map { |arg| ArgSerializer.new(arg).serialize }.join("")
      end

      def uint32_capacity
        4
      end
    end
  end
end