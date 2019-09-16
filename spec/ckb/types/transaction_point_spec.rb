RSpec.describe CKB::Types::TransactionPoint do
  let(:transaction_point_h) do
    {
      "block_number": "0x1",
      "index": "0x0",
      "tx_hash": "0x5ba156200c6310bf140fbbd3bfe7e8f03d4d5f82b612c1a8ec2501826eaabc17"
    }
  end

  let(:transaction_point) { CKB::Types::TransactionPoint::from_h(transaction_point_h) }

  it "from h" do
    expect(transaction_point).to be_a(CKB::Types::TransactionPoint)
    %i(block_number index).each do |key|
      expect(transaction_point.public_send(key)).to eq transaction_point_h[key].hex
    end
  end

  it "to_h" do
    expect(
      transaction_point.to_h
    ).to eq transaction_point_h
  end
end
