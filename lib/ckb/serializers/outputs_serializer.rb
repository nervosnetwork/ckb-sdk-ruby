# frozen_string_literal: true

module CKB
  module Serializers
    class OutputsSerializer
      include DynVecSerializer

      # @param outputs [CKB::Types::Output[]]
      def initialize(outputs)
        @outputs = outputs
        @items_count = outputs.count
      end

      private

      attr_reader :outputs, :items_count

      def item_layouts
        return "" if items_count == 0

        outputs.map { |output| OutputSerializer.new(output).serialize }.join("")
      end

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        outputs.each.with_index(1) do |_output, index|
          break if outputs[index].nil?

          output = outputs[index - 1]
          offsets << offset0 += OutputSerializer.new(output).capacity
        end

        offsets
      end
    end
  end
end
