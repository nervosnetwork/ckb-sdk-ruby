RSpec.describe CKB::Types::TxPoolInfo do
  let(:tx_pool_info_h) do
    {
      "last_txs_updated_at": "0x0",
      "orphan": "0x0",
      "pending": "0x1",
      "proposed": "0x0",
      "total_tx_cycles": "0xc",
      "total_tx_size": "0x112",
      "min_fee_rate": "0x3e8",
      "tip_hash": "0xa5f5c85987a15de25661e5a214f2c1449cd803f071acc7999820f25246471f40",
      "tip_number": "0x400"
    }
  end

  let(:tx_pool_info) { CKB::Types::TxPoolInfo.from_h(tx_pool_info_h) }

  it "from h" do
    expect(tx_pool_info).to be_a(CKB::Types::TxPoolInfo)
    tx_pool_info_h.each do |key, value|
      if key != :tip_hash
        expect(tx_pool_info.public_send(key)).to eq value.hex
      else
        expect(tx_pool_info.public_send(key)).to eq value
      end
    end
  end

  it "to_h" do
    expect(
      tx_pool_info.to_h
    ).to eq tx_pool_info_h
  end
end
