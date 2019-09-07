# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointIndexSerializer
      include BaseSerializer

      # @param index [String] number
      def initialize(index)
        @uint32_serializer = Uint32Serializer.new(index)
      end

      private

      attr_reader :uint32_serializer

      def layout
        body
      end

      def body
        uint32_serializer.serialize[2..-1]
      end
    end
  end
end
