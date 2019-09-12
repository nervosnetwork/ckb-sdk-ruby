RSpec.describe CKB::Types::CellInfo do
  let(:cell_info_h_with_data) do
    {
      output: {
        capacity: "11700000000",
        lock: {
          code_hash: "0xb35557e7e9854206f7bc13e3c3a7fa4cf8892c84a09237fb0aab40aab3771eee",
          args: [],
          hash_type: "data"
        },
        type: nil
      },
      data: {
        content: "0x02000000cda436b589c46398456a05f2f1b3fc4b3ac42d2e78bc077ee237747cf6a9627e03000000cda436b589c46398456a05f2f1b3fc4b3ac42d2e78bc077ee237747cf6a9627e01000000",
        hash: "0x9992e7e858b12d557f80edcc661fc1d4b86a98d077c0f0b6655eca38df4e2458"
      }
    }
  end

  let(:cell_info_h_without_data) do
    {
      output: {
        capacity: "11700000000",
        lock: {
          code_hash: "0xb35557e7e9854206f7bc13e3c3a7fa4cf8892c84a09237fb0aab40aab3771eee",
          args: [],
          hash_type: "data"
        },
        type: nil
      },
      data: nil
    }
  end

  it "from_h_with_data" do
    cell_info = CKB::Types::CellInfo.from_h(cell_info_h_with_data)
    expect(cell_info).to be_a(CKB::Types::CellInfo)
  end

  it "from_h_without_data" do
    cell_info = CKB::Types::CellInfo.from_h(cell_info_h_without_data)
    expect(cell_info).to be_a(CKB::Types::CellInfo)
  end
end
