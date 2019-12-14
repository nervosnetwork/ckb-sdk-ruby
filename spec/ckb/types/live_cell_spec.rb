RSpec.describe CKB::Types::LiveCell do
  let(:live_cell_h) do
    {
      "cell_output": {
        "capacity": "0x1d1a94a200",
        "lock": {
            "args": [],
            "code_hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5",
            "hash_type": "data"
        },
        "type": nil
    },
    "created_by": {
      "block_number": "0x1",
      "index": "0x0",
      "tx_hash": "0x5ba156200c6310bf140fbbd3bfe7e8f03d4d5f82b612c1a8ec2501826eaabc17"
    },
    "cellbase": false,
    "output_data_len": "0x0"
    }
  end

  let(:live_cell) { CKB::Types::LiveCell.from_h(live_cell_h) }

  it "from_h" do
    expect(live_cell).to be_a(CKB::Types::LiveCell)
    expect(live_cell.cell_output).to be_a(CKB::Types::Output)
    expect(live_cell.created_by).to be_a(CKB::Types::TransactionPoint)
    expect(live_cell.cellbase).to eq live_cell_h[:cellbase]
    expect(live_cell.output_data_len).to eq live_cell_h[:output_data_len].hex
  end

  it "to_h" do
    expect(
      live_cell.to_h
    ).to eq live_cell_h
  end
end
