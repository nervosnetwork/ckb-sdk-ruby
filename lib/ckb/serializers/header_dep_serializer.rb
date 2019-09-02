# frozen_string_literal: true

module CKB
  module Serializers
    class HeaderSerializer
      # @param header_dep [String]
      def initialize(header_dep)
        @header_dep = header_dep
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :header_dep

      def layout
        body
      end

      def body
        header_dep
      end
    end
  end
end