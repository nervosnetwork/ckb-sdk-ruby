# frozen_string_literal: true

module CKB
  module TransactionSize
    SERIALIZED_OFFSET_BYTESIZE = 4

    class << self
      def base_size
        68 + SERIALIZED_OFFSET_BYTESIZE
      end

      def every_cell_deps
        37
      end

      def every_header_deps
        32
      end

      def every_input
        44
      end

      def every_output(output)
        SERIALIZED_OFFSET_BYTESIZE + CKB::Utils.hex_to_bin(CKB::Serializers::OutputSerializer.new(output).serialize).bytesize
      end

      def every_witness(witness)
        SERIALIZED_OFFSET_BYTESIZE + CKB::Utils.hex_to_bin(CKB::Serializers::WitnessSerializer.new(witness).serialize).bytesize
      end

      def every_secp_witness(extra_data = nil)
        base = SERIALIZED_OFFSET_BYTESIZE + 69
        return base if extra_data.nil?

        base + CKB::Utils.hex_to_bin(extra_data).bytesize
      end

      def every_outputs_data(data)
        SERIALIZED_OFFSET_BYTESIZE + CKB::Utils.hex_to_bin(CKB::Serializers::OutputDataSerializer.new(data).serialize).bytesize
      end
    end
  end
end
