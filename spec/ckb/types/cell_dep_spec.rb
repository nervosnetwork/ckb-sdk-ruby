RSpec.describe CKB::Types::CellDep do
  let(:cell_dep_h) do
    {
      out_point: { tx_hash: "0x716842f09fa3022707bb7ad6a4f48eae2d886b3e6414d9e2e2aa8422510fe871", index: "0" },
      dep_type: "code"
    }
  end

  it "from_h" do
    cell_dep = CKB::Types::CellDep.from_h(cell_dep_h)
    expect(cell_dep).to be_a(CKB::Types::CellDep)
  end
end
