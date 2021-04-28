# frozen_string_literal: true

RSpec.describe CKB::Indexer::API do
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  it "get cells capacity" do
    script = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                                    hash_type: "type", args: "0xda648442dbb7347e467d1d09da13e5cd3a0ef0e1")
    search_key = CKB::Indexer::Types::SearchKey.new(script, "lock")
    result = CKB::Indexer::API.new.get_cells_capacity(search_key)
    expect(result).to be_a(CKB::Indexer::Types::CellsCapacity)
  end
end
