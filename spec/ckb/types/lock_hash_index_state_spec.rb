RSpec.describe CKB::Types::LockHashIndexState do
  let(:lock_hash_index_state_h) do
    {
      "block_hash": "0xd629a10a08fb0f43fcb97e948fc2b6eb70ebd28536490fe3864b0e40d08397d1",
      "block_number": "0x400",
      "lock_hash": "0xd8753dd87c7dd293d9b64d4ca20d77bb8e5f2d92bf08234b026e2d8b1b00e7e9"
    }
  end

  let(:lock_hash_index_state) { CKB::Types::LockHashIndexState.from_h(lock_hash_index_state_h) }

  it "from_h" do
    expect(lock_hash_index_state).to be_a(CKB::Types::LockHashIndexState)
    expect(lock_hash_index_state.block_number).to eq lock_hash_index_state_h[:block_number].hex
  end

  it "to_h" do
    expect(
      lock_hash_index_state.to_h
    ).to eq lock_hash_index_state_h
  end
end
