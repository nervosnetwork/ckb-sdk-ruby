RSpec.describe CKB::Types::AddressInfo do
  let(:address_info_h) do
    {
      "address": "/ip4/192.168.0.3/tcp/8115",
      "score": "0x1"
    }
  end

  let(:address_info) { CKB::Types::AddressInfo.from_h(address_info_h) }

  it "from h" do
    expect(address_info).to be_a(CKB::Types::AddressInfo)
    expect(address_info.address).to eq address_info_h[:address]
    expect(address_info.score).to eq address_info_h[:score].hex
  end

  it "to_h" do
    expect(
      address_info.to_h
    ).to eq address_info_h
  end
end
