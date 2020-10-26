# frozen_string_literal: true

module CKB
	module Types
		class TransactionProof
			attr_accessor :block_hash, :witnesses_root, :proof

			# @param block_hash [String]
			# @param witnesses_root [String]
			# @param proof CKB::Types::MerkleProof
			def initialize(block_hash:, witnesses_root:, proof:)
				@block_hash = block_hash
				@witnesses_root = witnesses_root
				@proof = proof
			end

			def to_h
				{
						block_hash: block_hash,
						witnesses_root: witnesses_root,
						proof: proof.to_h
				}
			end

			def self.from_h(hash)
				return if hash.nil?

				new(
						block_hash: hash[:block_hash],
						witnesses_root: hash[:witnesses_root],
						proof: MerkleProof.from_h(hash[:proof])
				)
			end
		end
	end
end
