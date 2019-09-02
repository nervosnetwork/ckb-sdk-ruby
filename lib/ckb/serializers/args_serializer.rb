# frozen_string_literal: true

module CKB
  module Serializers
    class ArgsSerializer
      include DynVecSerializer

      # @param args [String[]]
      def initialize(args)
        @args = args
        @items_count = args.count
      end

      private

      attr_reader :args, :items_count

      def offsets
        offset0 = (items_count + 1) * UINT32_CAPACITY
        offsets = [offset0]
        args.each.with_index(1) do |_arg, index|
          break if args[index].nil?

          offsets << offset0 += ArgSerializer.new(args[index - 1]).capacity
        end

        offsets
      end

      def item_layouts
        return "" if items_count == 0

        args.map { |arg| ArgSerializer.new(arg).serialize }.join("")
      end
    end
  end
end
