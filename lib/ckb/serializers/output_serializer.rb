# frozen_string_literal: true

module CKB
  module Serializers
    class OutputSerializer
      # @param output [CKB::Types::Output]
      def initialize(output)
        @capacity_serializer = CapacitySerializer.new(output.capacity)
        @lock_script_serializer = ScriptSerializer.new(output.lock)
        @type_script_serializer = ScriptSerializer.new(output.type) if output.type
        @items_count = 3
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :capacity_serializer, :lock_script_serializer, :type_script_serializer, :items_count

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        result = capacity_layout + lock_script_layout
        result + type_script_layout if type_script_serializer

        result
      end

      def type_script_layout
        type_script_serializer.serialize
      end

      def lock_script_layout
        lock_script_serializer.serialize
      end

      def capacity_layout
        capacity_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offset1 = offset0 + uint64_capacity
        offset2 = offset1 + lock_script_serializer.capacity

        [offset0, offset1, offset2]
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def uint32_capacity
        4
      end

      def uint64_capacity
        8
      end
    end
  end
end