RSpec.describe CKB::Types::CellDep do
  let(:cell_dep_h) do
    {
      "dep_type": "code",
      "out_point": {
          "index": "0x0",
          "tx_hash": "0x29f94532fb6c7a17f13bcde5adb6e2921776ee6f357adf645e5393bd13442141"
      }
    }
  end
  
  let(:cell_dep) { CKB::Types::CellDep.from_h(cell_dep_h) }

  it "from_h" do
    expect(cell_dep).to be_a(CKB::Types::CellDep)
    expect(cell_dep.dep_type).to eq cell_dep_h[:dep_type]
    expect(cell_dep.out_point).to be_a(CKB::Types::OutPoint)
  end

  it "to_h" do
    expect(
      cell_dep.to_h
    ).to eq cell_dep_h
  end
end
