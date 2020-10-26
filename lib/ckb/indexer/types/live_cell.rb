module CKB
	module Indexer
		module Types
			class LiveCell
				attr_reader :block_number, :out_point, :output, :output_data, :tx_index

				# @param block_number [String | Integer] integer or hex number
				# @param out_point [CKB::Types::OutPoint]
				# @param output [CKB::Types::Output]
				# @param output_data [string]
				# @param tx_index [String | Integer] integer or hex number
				def initialize(block_number:, out_point:, output:, output_data:, tx_index:)
					@block_number = Utils.to_int(block_number)
					@out_point = out_point
					@output = output
					@output_data = output_data
					@tx_index = Utils.to_int(tx_index)
				end

				def self.from_h(hash)
					return if hash.nil?

					new(
						block_number: hash[:block_number],
						out_point: CKB::Types::OutPoint.from_h(hash[:out_point]),
						output: CKB::Types::Output.from_h(hash[:output]),
						output_data: hash[:output_data],
						tx_index: hash[:tx_index]
					)
				end
			end
		end
	end
end
