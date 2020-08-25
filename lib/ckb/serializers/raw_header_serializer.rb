# frozen_string_literal: true

module CKB
  module Serializers
    class RawHeaderSerializer
      include StructSerializer

      # @param input [CKB::Types::BlockHeader]
      def initialize(header)
        @version_serializer = Uint32Serializer.new(header.version)
        @compact_target_serializer = Uint32Serializer.new(header.compact_target)
        @timestamp_serializer = Uint64Serializer.new(header.timestamp)
        @number_serializer = Uint64Serializer.new(header.number)
        @epoch_serializer = Uint64Serializer.new(header.epoch)
        @parent_hash_serializer = Byte32Serializer.new(header.parent_hash)
        @transactions_root_serializer = Byte32Serializer.new(header.transactions_root)
        @proposals_hash_serializer = Byte32Serializer.new(header.proposals_hash)
        @uncles_hash_serializer = Byte32Serializer.new(header.uncles_hash)
        @dao_serializer = Byte32Serializer.new(header.dao)
      end

      private

      attr_reader :version_serializer, :compact_target_serializer, :timestamp_serializer, :number_serializer, :epoch_serializer,
                  :parent_hash_serializer, :transactions_root_serializer, :proposals_hash_serializer, :uncles_hash_serializer, :dao_serializer

      def body
        version_layout + compact_target_layout + timestamp_layout + number_layout + epoch_layout +
        parent_hash_layout + transactions_root_layout + proposals_hash_layout + uncles_hash_layout + dao_layout
      end

      def version_layout
        version_serializer.serialize[2..-1]
      end

      def compact_target_layout
        compact_target_serializer.serialize[2..-1]
      end

      def timestamp_layout
        timestamp_serializer.serialize[2..-1]
      end

      def number_layout
        number_serializer.serialize[2..-1]
      end

      def epoch_layout
        epoch_serializer.serialize[2..-1]
      end

      def parent_hash_layout
        parent_hash_serializer.serialize[2..-1]
      end

      def transactions_root_layout
        transactions_root_serializer.serialize[2..-1]
      end

      def proposals_hash_layout
        proposals_hash_serializer.serialize[2..-1]
      end

      def uncles_hash_layout
        uncles_hash_serializer.serialize[2..-1]
      end

      def dao_layout
        dao_serializer.serialize[2..-1]
      end
    end
  end
end
