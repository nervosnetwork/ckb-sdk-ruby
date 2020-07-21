# frozen_string_literal: true

module CKB
  module Serializers
    class ArgSerializer
      include BaseSerializer

      # @param arg [String]
      def initialize(arg)
        arg = if arg
                arg.start_with?("0x") ? arg[2..-1] : arg
              else
                ""
              end
        items = arg.scan(/../)
        @bytes_serializer = FixVecSerializer.new(items, ByteSerializer)
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize[2..-1]
      end
    end
  end
end
