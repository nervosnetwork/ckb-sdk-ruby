RSpec.describe CKB::Types::CellTransaction do
  let(:cell_transaction_h) do
    {
      "consumed_by": nil,
      "created_by": {
          "block_number": "0x1",
          "index": "0x0",
          "tx_hash": "0x5ba156200c6310bf140fbbd3bfe7e8f03d4d5f82b612c1a8ec2501826eaabc17"
      }
    }
  end

  let(:cell_transaction) { CKB::Types::CellTransaction.from_h(cell_transaction_h) }

  it "from_h" do
    expect(cell_transaction).to be_a(CKB::Types::CellTransaction)
    expect(cell_transaction.created_by).to be_a(CKB::Types::TransactionPoint)
  end

  it "to_h" do
    expect(
      cell_transaction.to_h
    ).to eq cell_transaction_h
  end
end
