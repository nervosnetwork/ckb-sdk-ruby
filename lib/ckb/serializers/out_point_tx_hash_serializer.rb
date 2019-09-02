# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointTxHashSerializer
      # @param tx_hash [String]
      def initialize(tx_hash)
        @byte32_serializer = Byte32Serializer.new(tx_hash)
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :byte32_serializer

      def layout
        body
      end

      def body
        byte32_serializer.serialize
      end
    end
  end
end