# frozen_string_literal: true

module CKB
  module Serializers
    class ArgSerializer
      include BaseSerializer

      # @param arg [String]
      def initialize(arg)
        @bytes_serializer = BytesSerializer.new(arg)
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize
      end
    end
  end
end
