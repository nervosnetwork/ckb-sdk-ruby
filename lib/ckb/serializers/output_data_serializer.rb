# frozen_string_literal: true

module CKB
  module Serializers
    class OutputDataSerializer
      # @param output_data [String]
      def initialize(output_data)
        @output_data = output_data
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :output_data

      def layout
        return "" if output_data.nil?

        header + body
      end

      def header
        items_count = [body].pack("H*").bytesize
        [items_count].pack("V").unpack1("H*")
      end

      def body
        output_data
      end
    end
  end
end