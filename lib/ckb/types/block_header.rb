# frozen_string_literal: true

module CKB
  module Types
    class BlockHeader
      attr_accessor :difficulty, :hash, :number, :parent_hash, :nonce, :timestamp, :transactions_root, :proposals_hash, \
                  :uncles_count, :uncles_hash, :version, :witnesses_root, :epoch, :dao

      # @param difficulty [String] 0x...
      # @param hash [String] 0x...
      # @param number [String] number
      # @param parent_hash [String] 0x...
      # @param parent_hash [String] 0x...
      # @param nonce [String] decimal number
      # @param timestamp [String]
      # @param transactions_root [String] 0x...
      # @param proposals_root [String] 0x...
      # @param uncles_count [String] number
      # @param uncles_hash [String] 0x...
      # @param version [String] number
      # @param witnesses_root [String] 0x...
      # @param epoch [String] number
      # @param dao [String] 0x...
      # @param chain_root [String] 0x...
      def initialize(
        difficulty:,
        hash:,
        number:,
        parent_hash:,
        nonce:,
        timestamp:,
        transactions_root:,
        proposals_hash:,
        uncles_count:,
        uncles_hash:,
        version:,
        witnesses_root:,
        epoch:,
        dao: ,
        chain_root:
      )
        @difficulty = difficulty
        @hash = hash
        @number = number.to_s
        @parent_hash = parent_hash
        @nonce = nonce
        @timestamp = timestamp.to_s
        @transactions_root = transactions_root
        @proposals_hash = proposals_hash
        @uncles_count = uncles_count.to_s
        @uncles_hash = uncles_hash
        @version = version.to_s
        @witnesses_root = witnesses_root
        @epoch = epoch
        @dao = dao
        @chain_root = chain_root
      end

      def to_h
        {
          difficulty: @difficulty,
          hash: @hash,
          number: @number,
          parent_hash: parent_hash,
          nonce: nonce,
          timestamp: @timestamp,
          transactions_root: @transactions_root,
          proposals_hash: @proposals_hash,
          uncles_count: @uncles_count,
          uncles_hash: @uncles_hash,
          version: @version,
          witnesses_root: @witnesses_root,
          epoch: @epoch,
          dao: @dao,
          chain_root: @chain_root
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          difficulty: hash[:difficulty],
          hash: hash[:hash],
          number: hash[:number],
          parent_hash: hash[:parent_hash],
          nonce: hash[:nonce],
          timestamp: hash[:timestamp],
          transactions_root: hash[:transactions_root],
          proposals_hash: hash[:proposals_hash],
          uncles_count: hash[:uncles_count],
          uncles_hash: hash[:uncles_hash],
          version: hash[:version],
          witnesses_root: hash[:witnesses_root],
          epoch: hash[:epoch],
          dao: hash[:dao],
          chain_root: hash[:chain_root]
        )
      end
    end
  end
end
