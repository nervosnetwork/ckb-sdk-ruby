# frozen_string_literal: true

module CKB
  module Serializers
    class ArgSerializer
      # @param arg [String]
      def initialize(arg)
        @bytes_serializer = BytesSerializer.new(arg)
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize
      end
    end
  end
end