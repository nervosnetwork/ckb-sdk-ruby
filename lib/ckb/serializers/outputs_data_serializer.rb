# frozen_string_literal: true

module CKB
  module Serializers
    class OutputsDataSerializer
      include DynVecSerializer

      # @param outputs_data [String[]]
      def initialize(outputs_data)
        @outputs_data = outputs_data
        @items_count =  @outputs_data.count
      end

      private

      attr_reader :outputs_data, :items_count

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        outputs_data.each.with_index(1) do |_output_data, index|
          break if outputs_data[index].nil?

          offsets << offset0 += OutputDataSerializer.new(outputs_data[index - 1]).capacity
        end

        offsets
      end

      def item_layouts
        return "" if items_count == 0

        outputs_data.map { |output_data| OutputDataSerializer.new(output_data).serialize }.join("")
      end
    end
  end
end
