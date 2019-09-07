# frozen_string_literal: true

module CKB
  module Serializers
    class DepTypeSerializer
      include BaseSerializer

      # @param dep_type [String]
      def initialize(dep_type)
        @dep_type = dep_type
      end

      private

      attr_reader :dep_type

      def layout
        body
      end

      def body
        dep_type == "code" ? "00" : "01"
      end
    end
  end
end
