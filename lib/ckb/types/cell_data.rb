# frozen_string_literal: true

module CKB
  module Types
    class CellData
      attr_accessor :content, :hash

      # @param content [String]
      # @param hash [String]
      def initialize(content:, hash:)
        @content = content
        @hash = hash
      end

      def to_h
        {
          content: content,
          hash: hash
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          content: hash[:content],
          hash: hash[:hash]
        )
      end
    end
  end
end
