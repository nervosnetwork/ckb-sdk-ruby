# frozen_string_literal: true

module CKB
  module Types
    class BlockHeader
      attr_reader :difficulty, :hash, :number, :parent_hash, :seal, :timestamp, :transactions_root, :proposals_hash, \
                  :uncles_count, :uncles_hash, :version, :witnesses_root, :epoch

      # @param difficulty [String] 0x...
      # @param hash [String] 0x...
      # @param number [String] number
      # @param parent_hash [String] 0x...
      # @param seal [CKB::Types::Seal]
      # @param timestamp [String]
      # @param transactions_root [String] 0x...
      # @param proposals_root [String] 0x...
      # @param uncles_count [Integer] number
      # @param uncles_hash [String] 0x...
      # @param version [Integer]
      # @param witnesses_root [String] 0x...
      # @param epoch [String] number
      def initialize(
        difficulty:,
        hash:,
        number:,
        parent_hash:,
        seal:,
        timestamp:,
        transactions_root:,
        proposals_hash:,
        uncles_count:,
        uncles_hash:,
        version:,
        witnesses_root:,
        epoch:
      )
        @difficulty = difficulty
        @hash = hash
        @number = number.to_s
        @parent_hash = parent_hash
        @seal = seal
        @timestamp = timestamp.to_s
        @transactions_root = transactions_root
        @proposals_hash = proposals_hash
        @uncles_count = uncles_count.to_i
        @uncles_hash = uncles_hash
        @version = version
        @witnesses_root = witnesses_root
        @epoch = epoch
      end

      def to_h
        {
          difficulty: @difficulty,
          hash: @hash,
          number: @number.to_s,
          parent_hash: parent_hash,
          seal: @seal.to_h,
          timestamp: @timestamp,
          transactions_root: @transactions_root,
          proposals_hash: @proposals_hash,
          uncles_count: @uncles_count.to_i,
          uncles_hash: @uncles_hash,
          version: @version,
          witnesses_root: @witnesses_root,
          epoch: @epoch
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          difficulty: hash[:difficulty],
          hash: hash[:hash],
          number: hash[:number].to_s,
          parent_hash: hash[:parent_hash],
          seal: Seal.from_h(hash[:seal]),
          timestamp: hash[:timestamp],
          transactions_root: hash[:transactions_root],
          proposals_hash: hash[:proposals_hash],
          uncles_count: hash[:uncles_count],
          uncles_hash: hash[:uncles_hash],
          version: hash[:version],
          witnesses_root: hash[:witnesses_root],
          epoch: hash[:epoch]
        )
      end
    end
  end
end
