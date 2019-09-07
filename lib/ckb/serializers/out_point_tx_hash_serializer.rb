# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointTxHashSerializer
      include BaseSerializer

      # @param tx_hash [String]
      def initialize(tx_hash)
        @byte32_serializer = Byte32Serializer.new(tx_hash)
      end

      private

      attr_reader :byte32_serializer

      def layout
        body
      end

      def body
        byte32_serializer.serialize[2..-1]
      end
    end
  end
end
