# frozen_string_literal: true

module CKB
  module Types
    class Output
      attr_accessor :lock, :type, :out_point
      attr_reader :capacity

      # @param capacity [String]
      # @param lock [CKB::Types::Script]
      # @param type [CKB::Types::Script | nil]
      # @param out_point [CKB::Types::OutPoint | nil]
      def initialize(capacity:, lock:, type: nil, out_point: nil)
        @capacity = capacity.to_s
        @lock = lock
        @type = type
        @out_point = out_point
      end

      def capacity=(value)
        @capacity = value.to_s
      end

      # @param data [String] 0x...
      def calculate_bytesize(data)
        raise "Please provide a valid data" if data.nil?
        bytesize = 8 + Utils.hex_to_bin(data).bytesize + @lock.calculate_bytesize
        bytesize += @type.calculate_bytesize if @type
        bytesize
      end

      def calculate_min_capacity(data)
        Utils.byte_to_shannon(calculate_bytesize(data))
      end

      def to_h
        hash = {
          capacity: @capacity,
          lock: @lock.to_h,
          type: @type&.to_h
        }
        hash[:out_point] = @out_point if @out_point
        hash
      end

      def self.from_h(hash)
        return if hash.nil?

        type = Script.from_h(hash[:type]) if hash[:type]
        out_point = OutPoint.from_h(hash[:out_point]) if hash[:out_point]
        new(
          capacity: hash[:capacity],
          lock: Script.from_h(hash[:lock]),
          type: type,
          out_point: out_point
        )
      end
    end
  end
end
