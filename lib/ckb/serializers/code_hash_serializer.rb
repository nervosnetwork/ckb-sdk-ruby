# frozen_string_literal: true

module CKB
  module Serializers
    class CodeHashSerializer
      include BaseSerializer

      # @param code_hash [String]
      def initialize(code_hash)
        @item = if code_hash
                  code_hash.start_with?("0x") ? code_hash[2..-1] : code_hash
                else
                  ""
                end
      end

      private

      attr_reader :item

      def layout
        body
      end

      def body
        item
      end
    end
  end
end
