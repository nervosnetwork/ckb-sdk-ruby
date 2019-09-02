module CKB
  module Serializers
    module BaseSerializer
      def serialize
        layout
      end

      def capacity
        [layout].pack("H*").bytesize
      end
    end
  end
end
