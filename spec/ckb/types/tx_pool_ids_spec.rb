RSpec.describe CKB::Types::TxPoolIds do
  let(:tx_pool_ids_h) do
    {
      "pending": %w[0xa0ef4eb5f4ceeb08a4c8524d84c5da95dce2f608e0ca2ec8091191b0f330c6e3 0x0a365f660592e22ba0aaad94fc4bda8d8522c3f33c473fc65c14645deab4c0bf 0x0a365f660592e22ba0aaad94fc4bda8d8522c3f33c473fc65c14645deab4c0bf],
      "proposed": %w[0x19f8058273c5ed4b341f48503b49a97a76dc815f081b8b57309f9cf20b5139ae 0x6f14e3a5029c62c04c4447e736d7c9fb4907b0e479e9f163ca95baaad158fcc6]
    }
  end

  let(:tx_pool_ids) { CKB::Types::TxPoolIds.from_h(tx_pool_ids_h) }

  it "from h" do
    expect(tx_pool_ids).to be_a(CKB::Types::TxPoolIds)
    tx_pool_ids_h.each do |key, value|
      expect(tx_pool_ids.public_send(key)).to eq value
    end
  end

  it "to_h" do
    expect(
      tx_pool_ids.to_h
    ).to eq tx_pool_ids_h
  end
end
