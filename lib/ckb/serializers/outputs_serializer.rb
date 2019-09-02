# frozen_string_literal: true

module CKB
  module Serializers
    class OutputsSerializer
      # @param outputs [CKB::Types::Output[]]
      def initialize(outputs)
        @outputs = outputs
        @items_count = outputs.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :outputs, :items_count

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
        output_layouts
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def offsets_hex
        offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
      end

      def body_capacity
        [output_layouts].pack("H*").bytesize
      end

      def output_layouts
        return "" if items_count == 0

        outputs.map { |output| OutputSerializer.new(output).serialize }.join("")
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offsets = [offset0]
        outputs.each.with_index(1) do |_output, index|
          break if outputs[index].nil?

          output = outputs[index - 1]
          offsets << offset0 += OutputSerializer.new(output).capacity
        end

        offsets
      end

      def uint32_capacity
        4
      end
    end
  end
end