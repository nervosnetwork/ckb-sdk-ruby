# frozen_string_literal: true

RSpec.describe CKB::Indexer::Types::CellsCapacity do
  it "to_h" do
    cells_capacity = CKB::Indexer::Types::CellsCapacity.new(capacity: 1000 * 10**8, block_number: 1000,
                                                            block_hash: "0x96894ba272c44fdf843604ac82a1aafe67f9c5c2f074335a6d4daebe0d741de6")
    expect do
      cells_capacity.to_h
    end.not_to raise_error
  end

  it "from_h" do
    cells_capacity = CKB::Indexer::Types::CellsCapacity.new(capacity: 1000 * 10**8, block_number: 1000,
                                                            block_hash: "0x96894ba272c44fdf843604ac82a1aafe67f9c5c2f074335a6d4daebe0d741de6")
    cells_capacity = CKB::Indexer::Types::CellsCapacity.from_h(cells_capacity.to_h)
    expect(cells_capacity.capacity).to eq(1000 * 10**8)
    expect(cells_capacity.block_hash).to eq("0x96894ba272c44fdf843604ac82a1aafe67f9c5c2f074335a6d4daebe0d741de6")
    expect(cells_capacity.block_number).to eq(1000)
  end
end
