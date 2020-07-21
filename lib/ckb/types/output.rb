# frozen_string_literal: true

module CKB
  module Types
    class Output
      attr_accessor :lock, :type
      attr_reader :capacity

      # @param capacity [String | Integer] integer or hex number
      # @param lock [CKB::Types::Script]
      # @param type [CKB::Types::Script | nil]
      def initialize(capacity:, lock:, type: nil)
        @capacity = Utils.to_int(capacity)
        @lock = lock
        @type = type
      end

      def capacity=(value)
        @capacity = Utils.to_int(value)
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
        {
          capacity: Utils.to_hex(@capacity),
          lock: @lock.to_h,
          type: @type&.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        type = Script.from_h(hash[:type]) if hash[:type]
        new(
          capacity: hash[:capacity],
          lock: Script.from_h(hash[:lock]),
          type: type
        )
      end
    end
  end
end
