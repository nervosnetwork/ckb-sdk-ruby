# frozen_string_literal: true

module CKB
  module Types
    class HardForkFeature
      attr_accessor :rfc, :epoch_number

      # @param rfc [String]
      # @param epoch_number [Integer | String]
      def initialize(rfc:, epoch_number:)
        @rfc = rfc
        @epoch_number = CKB::Utils.to_int(epoch_number)
      end

      def to_h
        {
          rfc: rfc,
          epoch_number: CKB::Utils.to_hex(epoch_number)
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          rfc: hash[:rfc],
          epoch_number: hash[:epoch_number]
        )
      end
    end
  end
end
