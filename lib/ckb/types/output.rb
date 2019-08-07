# frozen_string_literal: true

module CKB
  module Types
    class Output
      attr_accessor :data_hash, :lock, :type, :out_point, :data
      attr_reader :capacity

      # @param capacity [String]
      # @param data: [String] 0x...
      # @param data_hash: [String] 0x...
      # @param lock [CKB::Types::Script]
      # @param type [CKB::Types::Script | nil]
      # @param out_point [CKB::Types::OutPoint | nil]
      def initialize(capacity:, data_hash: nil, lock:, type: nil, out_point: nil, data: "0x")
        @capacity = capacity.to_s
        @lock = lock
        @type = type
        @out_point = out_point
        if data_hash
          @data_hash = data_hash
          @data = nil
        elsif data == "0x"
          @data = data
          @data_hash = "0x0000000000000000000000000000000000000000000000000000000000000000"
        else
          @data = data
          @data_hash = CKB::Blake2b.hexdigest(CKB::Utils.hex_to_bin(data))
        end
      end

      def capacity=(value)
        @capacity = value.to_s
      end

      def calculate_bytesize
        raise "Don't know data" if @data.nil?
        bytesize = 8 + Utils.hex_to_bin(@data).bytesize + @lock.calculate_bytesize
        bytesize += @type.calculate_bytesize if @type
        bytesize
      end

      def calculate_min_capacity
        Utils.byte_to_shannon(calculate_bytesize)
      end

      def to_h(data = true)
        hash = {
          capacity: @capacity,
          lock: @lock.to_h,
          type: @type&.to_h
        }
        hash[:data_hash] = @data_hash if data_hash
        hash[:out_point] = @out_point if @out_point
        hash
      end

      def self.from_h(hash)
        return if hash.nil?

        type = Script.from_h(hash[:type]) if hash[:type]
        out_point = OutPoint.from_h(hash[:out_point]) if hash[:out_point]
        new(
          capacity: hash[:capacity],
          data_hash: hash[:data_hash],
          lock: Script.from_h(hash[:lock]),
          type: type,
          out_point: out_point
        )
      end
    end
  end
end
