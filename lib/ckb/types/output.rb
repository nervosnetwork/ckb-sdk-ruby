# frozen_string_literal: true

module CKB
  module Types
    class Output
      attr_reader :capacity, :data, :lock, :type

      # @param capacity [Integer | String]
      # @param data: [String] 0x...
      # @param lock [CKB::Types::Script]
      # @param type [CKB::Types::Script]
      def initialize(capacity:, data: "0x", lock:, type: nil)
        @capacity = capacity.to_i
        @data = data
        @lock = lock
        @type = type
      end

      def to_h
        {
          capacity: @capacity.to_s,
          data: @data,
          lock: @lock.to_h,
          type: @type&.to_h
        }
      end

      def self.from_h(hash)
        type = Script.from_h(hash[:type]) if hash[:type]
        new(
          capacity: hash[:capacity],
          data: hash[:data],
          lock: Script.from_h(hash[:lock]),
          type: type
        )
      end
    end
  end
end
