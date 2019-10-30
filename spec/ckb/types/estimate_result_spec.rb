RSpec.describe CKB::Types::EstimateResult do
  let(:result_h) do
    {
      "fee_rate": "0x7d0"
    }
  end

  let(:result) { CKB::Types::EstimateResult.from_h(result_h) }

  it "from_h" do
    expect(result).to be_a(CKB::Types::EstimateResult)
    expect(result.fee_rate).to eq 2000
  end

  it "to_h" do
    expect(
      result.to_h
    ).to eq result_h
  end
end
