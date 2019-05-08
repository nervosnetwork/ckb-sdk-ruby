# frozen_string_literal: true

module CKB
  module Types
    class Output
      attr_reader :capacity, :data, :lock, :type, :out_point

      # @param capacity [Integer | String]
      # @param data: [String] 0x...
      # @param lock [CKB::Types::Script]
      # @param type [CKB::Types::Script]
      def initialize(capacity:, data: "0x", lock:, type: nil, out_point: nil)
        @capacity = capacity.to_i
        @data = data
        @lock = lock
        @type = type
        @out_point = out_point
      end

      def to_h(data = true)
        hash = {
          capacity: @capacity.to_s,
          lock: @lock.to_h,
          type: @type&.to_h
        }
        hash[:data] = @data if data
        hash[:out_point] = @out_point if @out_point
        hash
      end

      def self.from_h(hash)
        return if hash.nil?

        type = Script.from_h(hash[:type]) if hash[:type]
        out_point = OutPoint.from_h(hash[:out_point]) if hash[:out_point]
        new(
          capacity: hash[:capacity],
          data: hash[:data],
          lock: Script.from_h(hash[:lock]),
          type: type,
          out_point: out_point
        )
      end
    end
  end
end
