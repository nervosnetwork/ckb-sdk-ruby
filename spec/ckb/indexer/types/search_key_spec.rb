# frozen_string_literal: true

RSpec.describe CKB::Indexer::Types::SearchKey do
	it "should raise error when script type is not CKB::Types::Script" do
		expect {
			CKB::Indexer::Types::SearchKey.new(123, "type")
		}.to raise_error(ArgumentError, "script type must be CKB::Types::Script")
	end

	it "should raise error when script_type is invalid" do
		expect {
			CKB::Indexer::Types::SearchKey.new(CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, args: "0x", hash_type: "type"), "t")
		}.to raise_error(ArgumentError, "invalid script_type: t")
	end
end