# frozen_string_literal: true

module CKB
	module Types
		class ProposalWindow
			attr_accessor :closest, :farthest

			# @param closest [Integer | String]
			# @param farthest [Integer | String]
			def initialize(closest:, farthest:)
				@closest = CKB::Utils.to_int(closest)
				@farthest = CKB::Utils.to_int(farthest)
			end

			def to_h
				{
					closest: CKB::Utils.to_hex(closest),
					farthest: CKB::Utils.to_hex(farthest)
				}
			end

			def self.from_h(hash)
				return if hash.nil?

				new(
					closest: hash[:closest],
					farthest: hash[:farthest]
				)
			end
		end
	end
end
