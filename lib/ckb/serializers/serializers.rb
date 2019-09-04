# frozen_string_literal: true

require_relative "base_serializer"
require_relative "fix_vec_serializer"
require_relative "dyn_vec_serializer"
require_relative "table_serializer"
require_relative "uint32_serializer"
require_relative "uint64_serializer"
require_relative "byte32_serializer"
require_relative "byte_serializer"
require_relative "code_hash_serializer"
require_relative "hash_type_serializer"
require_relative "arg_serializer"
require_relative "script_serializer"
require_relative "version_serializer"
require_relative "header_dep_serializer"
require_relative "dep_type_serializer"
require_relative "cell_dep_serializer"
require_relative "since_serializer"
require_relative "input_serializer"
require_relative "capacity_serializer"
require_relative "output_serializer"
require_relative "out_point_tx_hash_serializer"
require_relative "out_point_index_serializer"
require_relative "out_point_serializer"
require_relative "output_data_serializer"
require_relative "raw_transaction_serializer"

module CKB
  module Serializers
  end
end
