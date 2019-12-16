RSpec.describe CKB::Types::CellOutputWithOutPoint do
  let(:cell_output_with_out_point_h) do
    {
      "block_hash": "0x03935a4b5e3c03a9c1deb93a39183a9a116c16cff3dc9ab129e847487da0e2b8",
      "capacity": "0x1d1a94a200",
      "lock": {
          "args": [],
          "code_hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5",
          "hash_type": "data"
      },
      "out_point": {
          "index": "0x0",
          "tx_hash": "0x5ba156200c6310bf140fbbd3bfe7e8f03d4d5f82b612c1a8ec2501826eaabc17"
      },
      "cellbase": true,
      "output_data_len": "0x0",
      "type": {
        "args": [],
        "code_hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5",
        "hash_type": "data"
      }
    }
  end

  let(:cell_output_with_out_point) { CKB::Types::CellOutputWithOutPoint.from_h(cell_output_with_out_point_h) }

  it "from_h" do
    expect(cell_output_with_out_point).to be_a(CKB::Types::CellOutputWithOutPoint)
    expect(cell_output_with_out_point.lock).to be_a(CKB::Types::Script)
    expect(cell_output_with_out_point.type).to be_a(CKB::Types::Script)
    expect(cell_output_with_out_point.out_point).to be_a(CKB::Types::OutPoint)
    expect(cell_output_with_out_point.capacity).to eq cell_output_with_out_point_h[:capacity].hex
    expect(cell_output_with_out_point.output_data_len).to eq cell_output_with_out_point_h[:output_data_len].hex
    expect(cell_output_with_out_point.block_hash).to eq cell_output_with_out_point_h[:block_hash]
    expect(cell_output_with_out_point.cellbase).to eq cell_output_with_out_point_h[:cellbase]
  end

  it "to_h" do
    expect(
      cell_output_with_out_point.to_h
    ).to eq cell_output_with_out_point_h
  end
end
