RSpec.describe CKB::Types::Epoch do
  let(:epoch_h) do
    {
      "compact_target": "0x7a1200",
      "length": "0x708",
      "number": "0x1",
      "start_number": "0x3e8"
    }
  end

  let(:epoch) { CKB::Types::Epoch.from_h(epoch_h) }

  it "from_h" do
    expect(epoch).to be_a(CKB::Types::Epoch)
    epoch_h.keys.each do |key|
      expect(epoch.public_send(key)).to eq epoch_h[key].hex
    end
  end

  it "to_h" do
    expect(
      epoch.to_h
    ).to eq epoch_h
  end
end
