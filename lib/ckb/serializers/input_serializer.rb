# frozen_string_literal: true

module CKB
  module Serializers
    class InputSerializer
      include StructSerializer

      # @param input [CKB::Types::Input]
      def initialize(input)
        @out_point_serializer = OutPointSerializer.new(input.previous_output)
        @since_serializer = SinceSerializer.new(input.since)
      end

      private

      attr_reader :out_point_serializer, :since_serializer

      def body
        since_layout + out_point_layout
      end

      def since_layout
        since_serializer.serialize
      end

      def out_point_layout
        out_point_serializer.serialize
      end
    end
  end
end
