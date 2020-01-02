RSpec.describe CKB::Types::LockHashCapacity do
  let(:lock_hash_capacity_h) do
    {
      "block_number": "0x400",
      "capacity": "0xb00fb84df292",
      "cells_count": "0x3f5"
    }
  end

  let(:lock_hash_capacity) { CKB::Types::LockHashCapacity.from_h(lock_hash_capacity_h) }

  it "from_h" do
    expect(lock_hash_capacity).to be_a(CKB::Types::LockHashCapacity)
    expect(lock_hash_capacity.capacity).to eq lock_hash_capacity_h[:capacity].hex
    expect(lock_hash_capacity.cells_count).to eq lock_hash_capacity_h[:cells_count].hex
    expect(lock_hash_capacity.block_number).to eq lock_hash_capacity_h[:block_number].hex
  end

  it "to_h" do
    expect(
      lock_hash_capacity.to_h
    ).to eq lock_hash_capacity_h
  end
end
