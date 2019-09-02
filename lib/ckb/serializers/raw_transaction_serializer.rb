# frozen_string_literal: true

module CKB
  module Serializers
    class RawTransactionSerializer
      # @param transaction [CKB::Types::Transaction]
      def initialize(transaction)
        @version_serializer = VersionSerializer.new(transaction.version)
        @cell_deps_serializer = CellDepsSerializer.new(transaction.cell_deps)
        @header_deps_serializer = HeaderDepsSerializer.new(transaction.header_deps)
        @header_deps = transaction.header_deps
        @inputs_serializer = InputsSerializer.new(transaction.inputs)
        @outputs_serializer = OutputsSerializer.new(transaction.outputs)
        @outputs_data_serializer = OutputsDataSerializer.new(transaction.outputs_data)
        @items_count = 6
      end

      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end

      private

      attr_reader :version_serializer, :cell_deps_serializer, :header_deps_serializer, :header_deps, :inputs_serializer, :outputs_serializer, :outputs_data_serializer, :items_count

      def layout
        header + body
      end

      def header
        offsets_hex = offsets.map {|offset| [offset].pack("V").unpack1("H*")}.join("")
        full_length_hex + offsets_hex
      end

      def body
        version_layout + cell_deps_layout + header_deps_layout + inputs_layout + outputs_layout + outputs_data_layout
      end

      def version_layout
        version_serializer.serialize
      end

      def offsets
        offset0 = (items_count + 1) * uint32_capacity
        offset1 = offset0 + uint32_capacity
        offset2 = offset1 + cell_deps_capacity
        offset3 = offset2 + header_deps_capacity
        offset4 = offset3 + inputs_capacity
        offset5 = offset4 + outputs_capacity

        [offset0, offset1, offset2, offset3, offset4, offset5]
      end

      def full_length_hex
        full_length = (items_count + 1) * uint32_capacity + body_capacity
        [full_length].pack("V").unpack1("H*")
      end

      def body_capacity
        [body].pack("H*").bytesize
      end

      def cell_deps_layout
        cell_deps_serializer.serialize
      end

      def cell_deps_capacity
        cell_deps_serializer.capacity
      end

      def header_deps_layout
        header_deps_serializer.serialize
      end

      def header_deps_capacity
        [header_deps_layout].pack("H*").bytesize
      end

      def inputs_layout
        inputs_serializer.serialize
      end

      def inputs_capacity
        inputs_serializer.capacity
      end

      def outputs_layout
        outputs_serializer.serialize
      end

      def outputs_capacity
        outputs_serializer.capacity
      end

      def outputs_data_layout
        outputs_data_serializer.serialize
      end

      def uint32_capacity
        4
      end
    end
  end
end