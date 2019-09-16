RSpec.describe CKB::Types::OutPoint do
  let(:out_point_h) do
    {
      "index": "0x0",
      "tx_hash": "0x29f94532fb6c7a17f13bcde5adb6e2921776ee6f357adf645e5393bd13442141"
    }
  end

  let(:out_point) { CKB::Types::OutPoint.from_h(out_point_h) }

  it "from_h" do
    expect(out_point).to be_a(CKB::Types::OutPoint)
    expect(out_point.index).to eq out_point_h[:index].hex
  end

  it "to_h" do
    expect(
      out_point.to_h
    ).to eq out_point_h
  end
end
