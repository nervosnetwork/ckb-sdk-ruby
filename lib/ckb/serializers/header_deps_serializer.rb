# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderDepsSerializer
      # @param header_deps [String[]]
      def initialize(header_deps)
        @header_deps = header_deps
        @items_count = header_deps.count
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :header_deps, :items_count

      def layout
        header + body
      end

      def header
        [items_count].pack("V").unpack1("H*")
      end

      def body
        header_dep_layouts
      end

      def out_point_layout
        out_point_serializer.serialize
      end

      def body_capacity
        [header_dep_layouts].pack("H*").bytesize
      end

      def header_dep_layouts
        return "" if items_count == 0

        header_deps.map { |header_dep| HeaderDepSerializer.new(header_dep).serialize }.join("")
      end
    end
  end
end