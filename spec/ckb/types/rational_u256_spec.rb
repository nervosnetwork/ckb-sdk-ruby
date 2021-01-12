RSpec.describe CKB::Types::RationalU256 do
  let(:rationalu256_h) do
    {
      denom: "0x28",
      numer: "0x1"
    }
  end

  let(:rationalu256) { CKB::Types::RationalU256.from_h(rationalu256_h) }

  it "from h" do
    expect(rationalu256).to be_a(CKB::Types::RationalU256)
    rationalu256_h.each do |key, value|
      expect(rationalu256.public_send(key)).to eq value
    end
  end

  it "to_h" do
    expect(
      rationalu256.to_h
    ).to eq rationalu256_h
  end
end
