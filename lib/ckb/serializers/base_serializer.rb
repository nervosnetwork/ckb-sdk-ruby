# frozen_string_literal: true

module CKB
  module Serializers
    module BaseSerializer
      def serialize
        "0x#{layout}"
      end

      def capacity
        [layout].pack("H*").bytesize
      end
    end
  end
end
