# frozen_string_literal: true

module CKB
  module Types
    class CellOutputWithOutPoint
      attr_accessor :lock, :out_point, :block_hash, :cellbase, :type
      attr_reader :capacity, :output_data_len

      # @param capacity [String | Integer] integer or hex number
      # @param lock [CKB::Types::Script]
      # @param out_point [CKB::Types::OutPoint]
      # @param block_hash [String]
      # @param cellbase: [Boolean]
      # @param output_data_len [Integer]
      # @param type [CKB::Types::Script | nil]
      def initialize(capacity:, lock:, out_point:, block_hash:, cellbase:, output_data_len:, type: nil)
        @lock = lock
        @out_point = out_point
        @block_hash = block_hash
        @cellbase = cellbase
        @type = type

        self.capacity = capacity
        self.output_data_len = output_data_len
      end

      def capacity=(value)
        @capacity = Utils.to_int(value)
      end

      def output_data_len=(value)
        @output_data_len = Utils.to_int(value)
      end

      def to_h
        {
          capacity: Utils.to_hex(@capacity),
          lock: @lock.to_h,
          block_hash: @block_hash,
          out_point: @out_point.to_h,
          cellbase: @cellbase,
          type: @type ? @type.to_h : nil,
          output_data_len: Utils.to_hex(@output_data_len)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          capacity: hash[:capacity],
          lock: Script.from_h(hash[:lock]),
          out_point: OutPoint.from_h(hash[:out_point]),
          block_hash: hash[:block_hash],
          output_data_len: hash[:output_data_len],
          cellbase: hash[:cellbase],
          type: Script.from_h(hash[:type])
        )
      end
    end
  end
end
