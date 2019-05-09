# frozen_string_literal: true

module CKB
  module Types
    class Uncle
      attr_reader :proposals, :header

      # @param header [CKB::Type::BlockHeader]
      def initialize(proposals:, header:)
        @proposals = proposals
        @header = header
      end

      def to_h
        {
          proposals: @proposals,
          header: header.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          proposals: hash[:proposals],
          header: BlockHeader.from_h(hash[:header])
        )
      end
    end
  end
end

