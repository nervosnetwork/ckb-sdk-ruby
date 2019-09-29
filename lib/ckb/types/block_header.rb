# frozen_string_literal: true

module CKB
  module Types
    class BlockHeader
      attr_accessor :difficulty, :hash, :number, :parent_hash, :nonce, :timestamp, :transactions_root, :proposals_hash, \
                    :uncles_hash, :version, :witnesses_root, :epoch, :dao

      # @param difficulty [String | Integer] integer or hex number
      # @param hash [String] 0x...
      # @param number [String | Integer] integer or hex number
      # @param parent_hash [String] 0x...
      # @param nonce [String | Integer] integer or hex number
      # @param timestamp [String | Integer] integer or hex number
      # @param transactions_root [String] 0x...
      # @param proposals_hash [String] 0x...
      # @param uncles_hash [String] 0x...
      # @param version [String | Integer] integer or hex number
      # @param witnesses_root [String] 0x...
      # @param epoch [String | Integer] integer or hex number
      # @param dao [String] 0x...
      def initialize(
        difficulty:,
        hash:,
        number:,
        parent_hash:,
        nonce:,
        timestamp:,
        transactions_root:,
        proposals_hash:,
        uncles_hash:,
        version:,
        witnesses_root:,
        epoch:,
        dao:
      )
        @difficulty = Utils.to_int(difficulty)
        @hash = hash
        @number = Utils.to_int(number)
        @parent_hash = parent_hash
        @nonce = Utils.to_int(nonce)
        @timestamp = Utils.to_int(timestamp)
        @transactions_root = transactions_root
        @proposals_hash = proposals_hash
        @uncles_hash = uncles_hash
        @version = Utils.to_int(version)
        @witnesses_root = witnesses_root
        @epoch = Utils.to_int(epoch)
        @dao = dao
      end

      def to_h
        {
          difficulty: Utils.to_hex(@difficulty),
          hash: @hash,
          number: Utils.to_hex(@number),
          parent_hash: parent_hash,
          nonce: Utils.to_hex(nonce),
          timestamp: Utils.to_hex(@timestamp),
          transactions_root: @transactions_root,
          proposals_hash: @proposals_hash,
          uncles_hash: @uncles_hash,
          version: Utils.to_hex(@version),
          witnesses_root: @witnesses_root,
          epoch: Utils.to_hex(@epoch),
          dao: @dao,
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
          uncles_hash: hash[:uncles_hash],
          version: hash[:version],
          witnesses_root: hash[:witnesses_root],
          epoch: hash[:epoch],
          dao: hash[:dao],
        )
      end
    end
  end
end
