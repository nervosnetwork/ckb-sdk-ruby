# frozen_string_literal: true

module CKB
  module Serializers
    class ArgSerializer
      # @param arg [String]
      def initialize(arg)
        @arg = arg
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :arg

      def layout
        return "" if arg.nil?

        header + body
      end

      def header
        items_count = [body].pack("H*").bytesize
        [items_count].pack("V").unpack1("H*")
      end

      def body
        arg
      end
    end
  end
end