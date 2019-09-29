RSpec.describe CKB::Types::BlockHeader do
  let(:block_header_h) do
    {
      "dao": "0x0100000000000000005827f2ba13b000d77fa3d595aa00000061eb7ada030000",
      "difficulty": "0x7a1200",
      "epoch": "0x1",
      "hash": "0xd629a10a08fb0f43fcb97e948fc2b6eb70ebd28536490fe3864b0e40d08397d1",
      "nonce": "0x0",
      "number": "0x400",
      "parent_hash": "0x30a78d902d7c89ae41feaeb4652c79439e2224a3a32bc0f12059f71d86239d03",
      "proposals_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "timestamp": "0x5cd2b117",
      "transactions_root": "0x8ad0468383d0085e26d9c3b9b648623e4194efc53a03b7cd1a79e92700687f1e",
      "uncles_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "version": "0x0",
    }
  end

  let(:block_header) { CKB::Types::BlockHeader.from_h(block_header_h) }

  it "from_h" do
    expect(block_header).to be_a(CKB::Types::BlockHeader)
    number_keys = %i(difficulty epoch nonce number timestamp version)
    number_keys.each do |key|
      expect(block_header.public_send(key)).to eq block_header_h[key].hex
    end
    (block_header_h.keys - number_keys).each do |key|
      expect(block_header.public_send(key)).to eq block_header_h[key]
    end
  end

  it "to_h" do
    expect(
      block_header.to_h
    ).to eq block_header_h
  end

  it "block header should contains correct attributes" do
    skip "not test api" if ENV["SKIP_RPC_TESTS"]

    api = CKB::API.new
    tip_header = api.get_tip_header
    expected_attributes = %w(dao difficulty epoch hash nonce number parent_hash proposals_hash timestamp transactions_root uncles_hash version)

    expect(expected_attributes).to eq(tip_header.instance_variables.map { |attribute| attribute.to_s.gsub("@", "") }.sort)
  end
end
