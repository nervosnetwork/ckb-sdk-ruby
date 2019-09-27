# frozen_string_literal: true

module CKB
  module Types
    class UncleTemplate
      attr_accessor :hash, :required, :proposals, :header

      # @param hash [String] 0x..
      # @param required [Boolean]
      # @param proposals [String[]] 0x..
      # @param header [CKB::Type::BlockHeader]
      def initialize(hash:, required:, proposals:, header:)
        @hash = hash
        @required = required
        @proposals = proposals
        @header = header
      end

      def to_h
        {
          hash: hash,
          required: required,
          proposals: proposals,
          header: header.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          required: hash[:required],
          proposals: hash[:proposals],
          header: BlockHeader.from_h(hash[:header])
        )
      end
    end
  end
end

