# frozen_string_literal: true

module CKB
  module Serializers
    class BytesOptSerializer
      include BaseSerializer

      # @param bytes [String]
      def initialize(bytes = "")
        bytes = bytes.start_with?("0x") ? bytes[2..-1] : bytes
        binding.pry
        if !bytes.empty?
          items = bytes.scan(/../)
          @bytes_serializer = FixVecSerializer.new(items, ByteSerializer)
        else
          @bytes_serializer = OpenStruct.new(serialize: "0x")
        end
      end

      private

      attr_reader :bytes_serializer

      def layout
        bytes_serializer.serialize[2..-1]
      end
    end
  end
end
