# frozen_string_literal: true

module CKB
	module Types
		class RationalU256
			attr_accessor :denom, :numer

			# @param denom [String]
			# @param numer [String]
			def initialize(denom:, numer:)
				@denom = denom
				@numer = numer
			end

			def to_h
				{
					denom: denom,
					numer: numer
				}
			end

			def self.from_h(hash)
				return if hash.nil?

				new(
					denom: hash[:denom],
					numer: hash[:numer]
				)
			end
		end
	end
end
