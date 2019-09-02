# frozen_string_literal: true

module CKB
  module Serializers
    class InputsSerializer
      include DynVecSerializer

      # @param inputs [CKB::Types::Input[]]
      def initialize(inputs)
        @inputs = inputs
        @items_count = inputs.count
      end

      private

      attr_reader :inputs, :items_count

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        inputs.each.with_index(1) do |_input, index|
          break if inputs[index].nil?

          input = inputs[index - 1]
          offsets << offset0 += InputSerializer.new(input).capacity
        end

        offsets
      end

      def item_layouts
        return "" if items_count == 0

        inputs.map { |input| InputSerializer.new(input).serialize }.join("")
      end
    end
  end
end
