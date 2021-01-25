# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderDepSerializer
      include BaseSerializer

      # @param header_dep [String]
      def initialize(header_dep)
        @item = if header_dep
                  header_dep.start_with?("0x") ? header_dep[2..-1] : header_dep
                else
                  ""
                end
      end

      private

      attr_reader :item

      def layout
        body
      end

      def body
        item
      end
    end
  end
end
