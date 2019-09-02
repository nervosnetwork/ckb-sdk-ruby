# frozen_string_literal: true

module CKB
  module Serializers
    class CodeHashSerializer
      include BaseSerializer

      # @param code_hash [String]
      def initialize(code_hash)
        @byte32_serializer = Byte32Serializer.new(code_hash)
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
