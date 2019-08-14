RSpec.describe CKB::Types::Epoch do
  let(:epoch_h) do
    {
      "difficulty": "0x3e8",
      "length": "1250",
      "number": "0",
      "start_number": "0"
    }
  end

  it "from_h" do
    epoch = CKB::Types::Epoch.from_h(epoch_h)
    expect(epoch).to be_a(CKB::Types::Epoch)
  end
end
