# frozen_string_literal: true

module CKB
  module Serializers
    class OutputsDataSerializer
      # @param outputs_data [String[]]
      def initialize(outputs_data)
        @outputs_data = outputs_data.map { |output_data| output_data.delete_prefix("0x") }
        @items_count =  @outputs_data.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :outputs_data, :items_count

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
        output_data_layouts
      end

      def out_point_layout
        out_point_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offsets = [offset0]
        outputs_data.each.with_index(1) do |_output_data, index|
          break if outputs_data[index].nil?

          offsets << offset0 += OutputDataSerializer.new(outputs_data[index - 1]).capacity
        end

        offsets
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [output_data_layouts].pack("H*").bytesize
      end

      def output_data_layouts
        return "" if items_count == 0

        outputs_data.map { |output_data| OutputDataSerializer.new(output_data).serialize }.join("")
      end

      def uint32_capacity
        4
      end
    end
  end
end