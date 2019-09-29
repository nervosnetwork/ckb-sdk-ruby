# frozen_string_literal: true

module CKB
  module Types
    class Epoch
      attr_accessor :compact_target, :length, :number, :start_number

      # @param compact_target [String | Integer] integer or hex number
      # @param length [String | Integer] integer or hex number
      # @param number [String | Integer] integer or hex number
      # @param start_number [String | Integer] integer or hex number
      def initialize(
        compact_target:,
        length:,
        number:,
        start_number:
      )
        @compact_target = Utils.to_int(compact_target)
        @length = Utils.to_int(length)
        @number = Utils.to_int(number)
        @start_number = Utils.to_int(start_number)
      end

      def to_h
        {
          compact_target: Utils.to_hex(@compact_target),
          length: Utils.to_hex(@length),
          number: Utils.to_hex(@number),
          start_number: Utils.to_hex(@start_number)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          compact_target: hash[:compact_target],
          length: hash[:length],
          number: hash[:number],
          start_number: hash[:start_number]
        )
      end
    end
  end
end
