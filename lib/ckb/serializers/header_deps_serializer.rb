# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderDepsSerializer
      include FixVecSerializer

      # @param header_deps [String[]]
      def initialize(header_deps)
        @header_deps = header_deps
        @items_count = header_deps.count
      end

      private

      attr_reader :header_deps, :items_count

      def item_layouts
        return "" if items_count == 0

        header_deps.map { |header_dep| HeaderDepSerializer.new(header_dep).serialize }.join("")
      end
    end
  end
end
