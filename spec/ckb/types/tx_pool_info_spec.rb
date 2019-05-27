RSpec.describe CKB::Types::TxPoolInfo do
  let(:tx_pool_info_h) do
    {
      "pending": "34",
      "proposed": "22",
      "orphan": "33",
      "total_tx_cycles": "12",
      "total_tx_size": "156",
      "last_txs_updated_at": "1555507787683"
    }
  end

  it "from h" do
    tx_pool_info = CKB::Types::TxPoolInfo.from_h(tx_pool_info_h)
    expect(tx_pool_info).to be_a(CKB::Types::TxPoolInfo)
    expect(tx_pool_info.pending).to eq tx_pool_info_h[:pending]
    expect(tx_pool_info.total_tx_cycles).to eq tx_pool_info_h[:total_tx_cycles]
    expect(tx_pool_info.total_tx_size).to eq tx_pool_info_h[:total_tx_size]
  end
end
