# frozen_string_literal: true

module CKB
  module Serializers
    class VersionSerializer
      include BaseSerializer

      # @param version [String]
      def initialize(version)
        @uint32_serializer = Uint32Serializer.new(version)
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
