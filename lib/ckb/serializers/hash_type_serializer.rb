# frozen_string_literal: true

module CKB
  module Serializers
    class HashTypeSerializer
      include BaseSerializer

      # @param hash_type [String]
      def initialize(hash_type)
        @hash_type = hash_type
      end

      private

      attr_reader :hash_type

      def layout
        body
      end

      def body
        hash_type == "data" ? "00" : "01"
      end
    end
  end
end
