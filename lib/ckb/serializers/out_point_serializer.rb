# frozen_string_literal: true

module CKB
  module Serializers
    class OutPointSerializer
      # @param out_point [CKB::Types::OutPoint]
      def initialize(out_point)
        @tx_hash_serializer = OutPointTxHashSerializer.new(out_point.tx_hash)
        @index_serializer = OutPointIndexSerializer.new(out_point.index)
        @items_count = 2
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :tx_hash_serializer, :index_serializer, :items_count

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        tx_hash_layout + index_layout
      end

      def index_layout
        index_serializer.serialize
      end

      def tx_hash_layout
        tx_hash_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offset1 = offset0 + byte32_capacity

        [offset0, offset1]
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def byte32_capacity
        32
      end

      def uint32_capacity
        4
      end
    end
  end
end