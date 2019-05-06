# frozen_string_literal: true

module CKB
  module Types
    class Script
      attr_reader :code_hash, :args

      # @param code_hash [String]
      # @param args [String[]]
      def initialize(code_hash:, args:)
        @code_hash = code_hash
        @args = args
      end

      def to_h
        {
          code_hash: @code_hash,
          args: @args
        }
      end

      def self.from_h(hash)
        new(
          code_hash: hash[:code_hash],
          args: hash[:args]
        )
      end
    end
  end
end
