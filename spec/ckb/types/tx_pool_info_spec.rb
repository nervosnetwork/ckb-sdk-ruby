RSpec.describe CKB::Types::TxPoolInfo do
  let(:tx_pool_info_h) do
    {
      "last_txs_updated_at": "0x0",
      "orphan": "0x0",
      "pending": "0x1",
      "proposed": "0x0",
      "total_tx_cycles": "0xc",
      "total_tx_size": "0x112",
      "min_fee_rate": "0x3e8"
    }
  end

  let(:tx_pool_info) { CKB::Types::TxPoolInfo.from_h(tx_pool_info_h) }

  it "from h" do
    expect(tx_pool_info).to be_a(CKB::Types::TxPoolInfo)
    tx_pool_info_h.each do |key, value|
      expect(tx_pool_info.public_send(key)).to eq value.hex
    end
  end

  it "to_h" do
    expect(
      tx_pool_info.to_h
    ).to eq tx_pool_info_h
  end
end
