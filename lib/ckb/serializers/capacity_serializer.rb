# frozen_string_literal: true

module CKB
  module Serializers
    class CapacitySerializer
      include BaseSerializer

      # @param capacity [String]
      def initialize(capacity)
        @uint64_serializer = Uint64Serializer.new(capacity)
      end

      private

      attr_reader :uint64_serializer

      def layout
        body
      end

      def body
        uint64_serializer.serialize[2..-1]
      end
    end
  end
end
