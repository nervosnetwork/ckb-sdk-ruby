# frozen_string_literal: true

module CKB
  module Types
    class BlockHeader
      attr_accessor :compact_target, :hash, :number, :parent_hash, :nonce, :timestamp, :transactions_root, :proposals_hash, \
                    :extra_hash, :version, :epoch, :dao

      # @param compact_target [String | Integer] integer or hex number
      # @param hash [String] 0x...
      # @param number [String | Integer] integer or hex number
      # @param parent_hash [String] 0x...
      # @param nonce [String | Integer] integer or hex number
      # @param timestamp [String | Integer] integer or hex number
      # @param transactions_root [String] 0x...
      # @param proposals_hash [String] 0x...
      # @param extra_hash [String] 0x...
      # @param version [String | Integer] integer or hex number
      # @param epoch [String | Integer] integer or hex number
      # @param dao [String] 0x...
      def initialize(
        compact_target:,
        hash:,
        number:,
        parent_hash:,
        nonce:,
        timestamp:,
        transactions_root:,
        proposals_hash:,
        extra_hash:,
        version:,
        epoch:,
        dao:
      )
        @compact_target = Utils.to_int(compact_target)
        @hash = hash
        @number = Utils.to_int(number)
        @parent_hash = parent_hash
        @nonce = Utils.to_int(nonce)
        @timestamp = Utils.to_int(timestamp)
        @transactions_root = transactions_root
        @proposals_hash = proposals_hash
        @extra_hash = extra_hash
        @version = Utils.to_int(version)
        @epoch = Utils.to_int(epoch)
        @dao = dao
      end

      def to_h
        {
          compact_target: Utils.to_hex(@compact_target),
          hash: @hash,
          number: Utils.to_hex(@number),
          parent_hash: parent_hash,
          nonce: Utils.to_hex(nonce),
          timestamp: Utils.to_hex(@timestamp),
          transactions_root: @transactions_root,
          proposals_hash: @proposals_hash,
          extra_hash: @extra_hash,
          version: Utils.to_hex(@version),
          epoch: Utils.to_hex(@epoch),
          dao: @dao
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          compact_target: hash[:compact_target],
          hash: hash[:hash],
          number: hash[:number],
          parent_hash: hash[:parent_hash],
          nonce: hash[:nonce],
          timestamp: hash[:timestamp],
          transactions_root: hash[:transactions_root],
          proposals_hash: hash[:proposals_hash],
          extra_hash: hash[:extra_hash],
          version: hash[:version],
          epoch: hash[:epoch],
          dao: hash[:dao]
        )
      end
    end
  end
end
