# frozen_string_literal: true

module CKB
  module Types
    class SerializedBlock
      attr_accessor :block, :cycles

      # @param block [CKB::Types::Block]
      # @param cycles [String[]]
      def initialize(block:, cycles:)
        @block = block
        @cycles = cycles
      end

      def to_h
        {
          block: block.to_h,
          cycles: cycles
        }
      end


      def self.from_h(hash)
        return if hash.nil?

        if hash.is_a?(String)
          return hash
        end

        new(
          block: hash[:block],
          cycles: hash[:cycles]
        )
      end
    end
  end
end
