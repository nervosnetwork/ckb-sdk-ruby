# frozen_string_literal: true

module CKB
  module Serializers
    class OutputSerializer
      include TableSerializer

      # @param output [CKB::Types::Output]
      def initialize(output)
        @capacity_serializer = CapacitySerializer.new(output.capacity)
        @lock_script_serializer = ScriptSerializer.new(output.lock)
        @type_script_serializer = ScriptSerializer.new(output.type) if output.type
        @items_count = 3
      end

      private

      attr_reader :capacity_serializer, :lock_script_serializer, :type_script_serializer, :items_count

      def layout
        header + body
      end

      def body
        result = capacity_layout + lock_script_layout
        result += type_script_layout if type_script_serializer

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
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offset1 = offset0 + UINT64_CAPACITY
        offset2 = offset1 + lock_script_serializer.capacity

        [offset0, offset1, offset2]
      end
    end
  end
end
