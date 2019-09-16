RSpec.describe CKB::Types::TransactionWithStatus do
  let(:transaction_with_status_h) do
    {
      "transaction": {
        "cell_deps": [
            {
                "dep_type": "code",
                "out_point": {
                    "index": "0x0",
                    "tx_hash": "0x29f94532fb6c7a17f13bcde5adb6e2921776ee6f357adf645e5393bd13442141"
                }
            }
        ],
        "hash": "0x13ebb4a177fbbbef800f9988cc1763d313cbe76c3aed3f15c6fa93b723d1a070",
        "header_deps": [
            "0xeca4e06e75df81c0247365f864a08c7ef0eec8a5c7d182a25e6c086408a97cd2"
        ],
        "inputs": [
            {
                "previous_output": {
                    "index": "0x0",
                    "tx_hash": "0x5ba156200c6310bf140fbbd3bfe7e8f03d4d5f82b612c1a8ec2501826eaabc17"
                },
                "since": "0x0"
            }
        ],
        "outputs": [
            {
                "capacity": "0x174876e800",
                "lock": {
                    "args": [],
                    "code_hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5",
                    "hash_type": "data"
                },
                "type": nil
            }
        ],
        "outputs_data": [
            "0x"
        ],
        "version": "0x0",
        "witnesses": []
      },
      "tx_status": {
          "block_hash": nil,
          "status": "pending"
      }
    }
  end

  let(:transaction_with_status) { CKB::Types::TransactionWithStatus::from_h(transaction_with_status_h) }

  it "from h" do
    expect(transaction_with_status).to be_a(CKB::Types::TransactionWithStatus)
    expect(transaction_with_status.transaction).to be_a(CKB::Types::Transaction)
    expect(transaction_with_status.tx_status).to be_a(CKB::Types::TxStatus)
  end

  it "to_h" do
    expect(
      transaction_with_status.to_h
    ).to eq transaction_with_status_h
  end
end
