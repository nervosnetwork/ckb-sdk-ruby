RSpec.describe CKB::Types::CellWithStatus do
  let(:cell_with_status_h) do
    {
      "cell": {
        "data": {
            "content": "0x1234",
            "hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5"
        },
        "output": {
            "capacity": "0x802665800",
            "lock": {
                "args": [],
                "code_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                "hash_type": "data"
            },
            "type": nil
        }
      },
      "status": "live"
    }
  end

  let(:cell_with_status) { CKB::Types::CellWithStatus.from_h(cell_with_status_h) }

  it "from_h" do
    expect(cell_with_status).to be_a(CKB::Types::CellWithStatus)
    expect(cell_with_status.cell).to be_a(CKB::Types::CellInfo)
  end

  it "to_h" do
    expect(
      cell_with_status.to_h
    ).to eq cell_with_status_h
  end
end
