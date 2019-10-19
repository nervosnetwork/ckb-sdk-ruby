# frozen_string_literal: true

module CKB
  module Serializers
    class WitnessSerializer
      include BaseSerializer

      # @param witness [String]
      def initialize(witness)
        witness ||= ""
        witness = witness.start_with?("0x") ? witness[2..-1] : witness
        items = witness.scan(/../)
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
