# frozen_string_literal: true

module CKB
  module Types
    class Witness
      attr_accessor :lock, :input_type, :output_type

      def initialize(
        lock: "",
        input_type: "",
        output_type: ""
      )
        @lock = lock
        @input_type = input_type
        @output_type = output_type
      end
    end
  end
end
