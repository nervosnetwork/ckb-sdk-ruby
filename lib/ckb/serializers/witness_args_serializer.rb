# frozen_string_literal: true

module CKB
  module Serializers
    class WitnessArgsSerializer
      include TableSerializer

      # @param witness [CKB::Types::Witness]
      def initialize(witness)
        @witness_for_input_lock_serializer = BytesOptSerializer.new(witness.lock)
        @witness_for_input_type_serializer = BytesOptSerializer.new(witness.input_type)
        @witness_for_output_type_serializer = BytesOptSerializer.new(witness.output_type)
        @items_count = 3
      end

      private

      attr_reader :witness_for_input_lock_serializer, :witness_for_input_type_serializer, :witness_for_output_type_serializer, :items_count

      def body
        witness_for_input_lock_layout + witness_for_input_type_layout + witness_for_output_type_layout
      end

      def offsets
        witness_args_offset0 = (items_count + 1) * UINT32_CAPACITY
        witness_args_offset1 = witness_args_offset0 + witness_for_input_lock_serializer.capacity
        witness_args_offset2 = witness_args_offset1 + witness_for_input_type_serializer.capacity

        [witness_args_offset0, witness_args_offset1, witness_args_offset2]
      end

      def witness_for_input_lock_layout
        witness_for_input_lock_serializer.serialize[2..-1]
      end

      def witness_for_input_type_layout
        witness_for_input_type_serializer.serialize[2..-1]
      end

      def witness_for_output_type_layout
        witness_for_output_type_serializer.serialize[2..-1]
      end
    end
  end
end
