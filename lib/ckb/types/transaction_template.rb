# frozen_string_literal: true

module CKB
  module Types
    class TransactionTemplate
      attr_accessor :hash, :required, :cycles, :depends, :data

      # @param hash [String] 0x..
      # @param required [Boolean]
      # @param cycles [String | Integer] integer or hex number
      # @param depends [String[] | Integer[]] integer[] or hex number[]
      # @param data [CKB::Type::Transaction]
      def initialize(hash:, required:, cycles:, depends:, data:)
        @hash = hash
        @required = required
        @cycles = Utils.to_int(cycles)
        @depends = depends.map { |depend| Utils.to_int(depend) }
        @data = data
      end

      def to_h
        {
          hash: hash,
          required: required,
          cycles: Utils.to_hex(cycles),
          depends: depends.map { |depend| Utils.to_hex(depend) },
          data: data.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          required: hash[:required],
          cycles: hash[:cycles],
          depends: hash[:depends],
          data: Transaction.from_h(hash[:data])
        )
      end
    end
  end
end
