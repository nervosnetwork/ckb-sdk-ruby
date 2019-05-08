# frozen_string_literal: true

module CKB
  module Types
    class Seal
      attr_reader :nonce, :proof

      # @param nonce [String] decimal number
      # @param proof [String] 0x...
      def initialize(nonce:, proof:)
        @nonce = nonce
        @proof = proof
      end

      def to_h
        {
          nonce: @nonce,
          proof: @proof
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          nonce: hash[:nonce],
          proof: hash[:proof]
        )
      end
    end

    class BlockHeader
      attr_reader :difficulty, :hash, :number, :parent_hash, :seal, :timestamp, :transactions_root, :proposals_hash, \
                  :uncles_count, :uncles_hash, :version, :witness_root, :epoch

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
        witness_root:,
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
        @witness_root = witness_root
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
          witness_root: @witness_root,
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
          witness_root: hash[:witnesses_root],
          epoch: hash[:epoch]
        )
      end
    end
  end
end
