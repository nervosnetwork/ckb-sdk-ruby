RSpec.describe CKB::Types::BannedAddress do
  let(:banned_address_h) do
    {
      address: "192.168.0.2/32",
      ban_until: "1840546800000",
      ban_reason: "test set_ban rpc",
      created_at: "1564116508000"
    }
  end

  it "from h" do
    banned_address = CKB::Types::BannedAddress::from_h(banned_address_h)
    expect(banned_address).to be_a(CKB::Types::BannedAddress)
  end
end
