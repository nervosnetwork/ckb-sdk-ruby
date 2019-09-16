RSpec.describe CKB::Types::BlockHeader do
  let(:block_header_h) do
    {
      :chain_root => "0x9f5ebec9c725c99487ec6d07e8ff0963ac5f8a75fcc15d26df1787353e980e4f",
      :dao => "0x010000000000000055309658678823000086285987fe0300008f6b7c5f6f0000",
      :difficulty => "0x100",
      :epoch => "0",
      :hash => "0x7ba460895460baa5b2a698bc3d400d33afbb64a0312ed57b1496304c011ade7a",
      :nonce => "2058764368806501667",
      :number => "15",
      :parent_hash => "0xe1a4178bc36e6abb4d3a5f00b9bac8b6e8e1e2f9b46b160e1d55b480e6247a1a",
      :proposals_hash => "0x0000000000000000000000000000000000000000000000000000000000000000",
      :timestamp => "1565665851354",
      :transactions_root => "0xde27dcbd81dd174ede0749df02a883d78215b2f20d7ec8ff395ed220872b764c",
      :uncles_count => "0",
      :uncles_hash => "0x0000000000000000000000000000000000000000000000000000000000000000",
      :version => "0",
      :witnesses_root => "0x3b84ab9739349ec9ba1bfb7da2662d3cb2f1a1e3ecc0470542fbf4b0bee25f67",
    }
  end

  it "from_h" do
    expect {
      CKB::Types::BlockHeader.from_h(block_header_h)
    }.not_to raise_error
  end

  it "to_h" do
    expect {
      block = CKB::Types::BlockHeader.from_h(block_header_h)
      block.to_h
    }.not_to raise_error
  end

  it "block header should contains correct attributes" do
    skip "not test api" if ENV["SKIP_RPC_TESTS"]

    api = CKB::API.new
    tip_header = api.get_tip_header
    expected_attributes = %w(chain_root dao difficulty epoch hash nonce number parent_hash proposals_hash timestamp transactions_root uncles_count uncles_hash version witnesses_root)

    expect(expected_attributes).to eq(tip_header.instance_variables.map { |attribute| attribute.to_s.gsub("@", "") }.sort)
  end
end
