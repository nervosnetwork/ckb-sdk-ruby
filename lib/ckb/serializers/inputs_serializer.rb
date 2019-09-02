# frozen_string_literal: true

module CKB
  module Serializers
    class InputsSerializer
      # @param inputs [CKB::Types::Input[]]
      def initialize(inputs)
        @inputs = inputs
        @items_count = inputs.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :inputs, :items_count

      def layout
        if items_count == 0
          [uint32_capacity].pack("V").unpack1("H*")
        else
          header + body
        end
      end

      def header
        full_length_hex + offsets_hex
      end

      def body
        input_layouts
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def offsets_hex
        offsets.map { |offset| [offset].pack("V").unpack1("H*") }.join("")
      end

      def body_capacity
        [input_layouts].pack("H*").bytesize
      end

      def input_layouts
        return "" if items_count == 0

        inputs.map { |input| InputSerializer.new(input).serialize }.join("")
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offsets = [offset0]
        inputs.each.with_index(1) do |_input, index|
          break if inputs[index].nil?

          input = inputs[index - 1]
          offsets << offset0 += InputSerializer.new(input).capacity
        end

        offsets
      end

      def uint32_capacity
        4
      end
    end
  end
end