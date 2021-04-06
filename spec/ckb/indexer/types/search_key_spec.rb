# frozen_string_literal: true

RSpec.describe CKB::Indexer::Types::SearchKey do
  it "should raise error when script type is not CKB::Types::Script" do
    expect do
      CKB::Indexer::Types::SearchKey.new(123, "type")
    end.to raise_error(ArgumentError, "script type must be CKB::Types::Script")
  end

  it "should raise error when script_type is invalid" do
    expect do
      CKB::Indexer::Types::SearchKey.new(
        CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, args: "0x",
                               hash_type: "type"), "t"
      )
    end.to raise_error(ArgumentError, "invalid script_type: t")
  end

  it "to_h" do
    type = CKB::Types::Script.new(code_hash: "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212",
                                  hash_type: "data", args: "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129")
    filter = CKB::Indexer::Types::SearchKeyFilter.new(output_data_len_range: [1000, 100_000], block_range: [1000, 10_000],
                                                      output_capacity_range: [1 * 10**8, 150 * 10**8], script: type)
    search_key = CKB::Indexer::Types::SearchKey.new(
      CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                             hash_type: "type", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb"), "lock", filter: filter
    )
    expect do
      search_key.to_h
    end.not_to raise_error
  end
end
