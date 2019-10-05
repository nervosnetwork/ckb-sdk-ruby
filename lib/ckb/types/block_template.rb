# frozen_string_literal: true

module CKB
  module Types
    class BlockTemplate
      attr_accessor :version, :compact_target, :current_time, :number, :epoch, :parent_hash, :cycles_limit,
                    :bytes_limit, :uncles_count_limit, :uncles, :transactions, :proposals, :cellbase, :work_id, :dao

      # @param version [String | Integer] integer or hex number
      # @param compact_target [String | Integer] integer or hex number
      # @param current_time [String | Integer] integer or hex number
      # @param number [String | Integer] integer or hex number
      # @param epoch [String | Integer] integer or hex number
      # @param parent_hash [String] 0x...
      # @param cycles_limit [String | Integer] integer or hex number
      # @param bytes_limit [String | Integer] integer or hex number
      # @param uncles_count_limit [String | Integer] integer or hex number
      # @param uncles [CKB::Types::UncleTemplate[]]
      # @param transactions [CKB::Types::TransactionTemplate[]]
      # @param proposals [String[]] 0x...
      # @param cellbase [CellbaseTemplate]
      # @param work_id [String | Integer] integer or hex number
      # @param dao [String] 0x...
      def initialize(
        version:,
        compact_target:,
        current_time:,
        number:,
        epoch:,
        parent_hash:,
        cycles_limit:,
        bytes_limit:,
        uncles_count_limit:,
        uncles:,
        transactions:,
        proposals:,
        cellbase:,
        work_id:,
        dao:
      )
        @version =  Utils.to_int(version)
        @compact_target = Utils.to_int(compact_target)
        @current_time = Utils.to_int(current_time)
        @number = Utils.to_int(number)
        @epoch = Utils.to_int(epoch)
        @parent_hash = parent_hash
        @cycles_limit = Utils.to_int(cycles_limit)
        @bytes_limit = Utils.to_int(bytes_limit)
        @uncles_count_limit = Utils.to_int(uncles_count_limit)
        @uncles = uncles
        @transactions = transactions
        @proposals = proposals
        @cellbase = cellbase
        @work_id = Utils.to_int(work_id)
        @dao = dao
      end

      def to_h
        {
          version: Utils.to_hex(version),
          compact_target: Utils.to_hex(compact_target),
          current_time: Utils.to_hex(current_time),
          number: Utils.to_hex(number),
          epoch: Utils.to_hex(epoch),
          parent_hash: parent_hash,
          cycles_limit: Utils.to_hex(cycles_limit),
          bytes_limit: Utils.to_hex(bytes_limit),
          uncles_count_limit: Utils.to_hex(uncles_count_limit),
          uncles: uncles.map(&:to_h),
          transactions: transactions.map(&:to_h),
          proposals: proposals,
          cellbase: cellbase.to_h,
          work_id: work_id,
          dao: dao
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          version: hash[:version],
          compact_target: hash[:compact_target],
          current_time: hash[:current_time],
          number: hash[:number],
          epoch: hash[:epoch],
          parent_hash: hash[:parent_hash],
          cycles_limit: hash[:cycles_limit],
          bytes_limit: hash[:bytes_limit],
          uncles_count_limit: hash[:uncles_count_limit],
          uncles: hash[:uncles],
          transactions: hash[:transactions],
          proposals: hash[:proposals],
          cellbase: hash[:cellbase],
          work_id: hash[:work_id],
          dao: hash[:dao]
        )
      end
    end
  end
end
