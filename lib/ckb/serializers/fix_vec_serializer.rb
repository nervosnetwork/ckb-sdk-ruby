module CKB
  module Serializers
    module FixVecSerializer
      include BaseSerializer

      private

      def layout
        header + body
      end

      def header
        [items_count].pack("V").unpack1("H*")
      end

      def body
        item_layouts
      end

      def body_capacity
        [body].pack("H*").bytesize
      end
    end
  end
end
