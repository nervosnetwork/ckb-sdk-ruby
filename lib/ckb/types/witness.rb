# frozen_string_literal: true

module CKB
  module Types
    class Witness
      attr_reader :data

      # @param data [String] 0x...
      def initialize(data:)
        @data = data
      end

      def to_h
        {
          data: @data
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          data: hash[:data]
        )
      end
    end
  end
end
