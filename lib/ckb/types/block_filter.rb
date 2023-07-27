# frozen_string_literal: true

module CKB
  module Types
    class BlockFilter
      attr_accessor :data, :hash

      # @param data [String]
      # @param hash [String]
      def initialize(data:, hash:)
        @data = data
        @hash = hash
      end

      def to_h
        {
          data: data,
          hash: hash
        }
      end


      def self.from_h(hash)
        return if hash.nil?

        new(
          data: hash[:data],
          hash: hash[:hash]
        )
      end
    end
  end
end
