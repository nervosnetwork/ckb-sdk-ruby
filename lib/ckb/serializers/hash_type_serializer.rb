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
        case hash_type
        when "data"
          "00"
        when "type"
          "01"
        when "data1"
          "02"
        end
      end
    end
  end
end
