# frozen_string_literal: true

module CKB
	module Indexer
		module Types
			class CellsCapacity
				attr_reader :block_number, :block_hash, :capacity

				# @param block_number [String | Integer] integer or hex number
				# @param block_hash [String]
				# @param capacity [String | Integer]
				def initialize(capacity:, block_number:, block_hash:)
					@capacity = Utils.to_int(capacity)
					@block_hash = block_hash
					@block_number = Utils.to_int(block_number)
				end

				def self.from_h(hash)
					return if hash.nil?

					new(
						capacity:  hash[:capacity],
						block_hash:  hash[:block_hash],
						block_number: hash[:block_number]
					)
				end

				def to_h
					{
						capacity: Utils.to_hex(capacity),
						block_hash: block_hash,
						block_number: block_number
					}
				end
			end
		end
	end
end
