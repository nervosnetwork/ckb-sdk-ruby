# frozen_string_literal: true

module CKB
  module Serializers
    class SinceSerializer
      include BaseSerializer

      # @param since [String]
      def initialize(since)
        @uint64_serializer = Uint64Serializer.new(since)
      end

      private

      attr_reader :uint64_serializer

      def layout
        body
      end

      def body
        uint64_serializer.serialize
      end
    end
  end
end
