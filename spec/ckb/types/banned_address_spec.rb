RSpec.describe CKB::Types::BannedAddress do
  let(:banned_address_h) do
    {
      "address": "192.168.0.2/32",
      "ban_reason": "test set_ban rpc",
      "ban_until": "0x1ac89236180",
      "created_at": "0x16bde533338"
    }
  end

  let(:banned_address) { CKB::Types::BannedAddress.from_h(banned_address_h) }

  it "from h" do
    expect(banned_address).to be_a(CKB::Types::BannedAddress)
    expect(banned_address.ban_reason).to eq banned_address_h[:ban_reason]
    expect(banned_address.address).to eq banned_address_h[:address]
    %i(ban_until created_at).each do |key|
      expect(banned_address.public_send(key)).to eq banned_address_h[key].hex
    end
  end

  it "to_h" do
    expect(
      banned_address.to_h
    ).to eq banned_address_h
  end
end
