# frozen_string_literal: true

module CKB
  module Types
    class TransactionAndWitnessProof
      attr_accessor :block_hash, :witnesses_proof, :transactions_proof

      # @param block_hash [String]
      # @param transactions_proof CKB::Types::MerkleProof
      # @param witnesses_proof CKB::Types::MerkleProof
      def initialize(block_hash:, transactions_proof:, witnesses_proof:)
        @block_hash = block_hash
        @transactions_proof = transactions_proof
        @witnesses_proof = witnesses_proof
      end

      def to_h
        {
          block_hash: block_hash,
          transactions_proof: transactions_proof.to_h,
          witnesses_proof: witnesses_proof.to_h
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          block_hash: hash[:block_hash],
          transactions_proof: MerkleProof.from_h(hash[:transactions_proof]),
          witnesses_proof: MerkleProof.from_h(hash[:witnesses_proof])
        )
      end
    end
  end
end
