RSpec.describe CKB::Types::CellData do
  let(:cell_data_h) do
    {
      content: { tx_hash: "0x02000000cda436b589c46398456a05f2f1b3fc4b3ac42d2e78bc077ee237747cf6a9627e03000000cda436b589c46398456a05f2f1b3fc4b3ac42d2e78bc077ee237747cf6a9627e01000000", index: "0" },
      hash: "0x9992e7e858b12d557f80edcc661fc1d4b86a98d077c0f0b6655eca38df4e2458"
    }
  end

  it "from_h" do
    cell_data = CKB::Types::CellData.from_h(cell_data_h)
    expect(cell_data).to be_a(CKB::Types::CellData)
  end
end
