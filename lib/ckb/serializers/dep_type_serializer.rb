# frozen_string_literal: true

module CKB
  module Serializers
    class DepTypeSerializer
      # @param dep_type [String]
      def initialize(dep_type)
        @dep_type = dep_type
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :dep_type

      def layout
        body
      end

      def body
        dep_type == "data" ? "00" : "01"
      end
    end
  end
end