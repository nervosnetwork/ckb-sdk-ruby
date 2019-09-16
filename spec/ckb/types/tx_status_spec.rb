RSpec.describe CKB::Types::TxStatus do
  let(:tx_status_h) do
    {
      "block_hash": nil,
      "status": "pending"
    }
  end

  let(:tx_status) { CKB::Types::TxStatus.from_h(tx_status_h) }

  it "from h" do
    expect(tx_status).to be_a(CKB::Types::TxStatus)
  end

  it "to_h" do
    expect(
      tx_status.to_h
    ).to eq tx_status_h
  end
end
