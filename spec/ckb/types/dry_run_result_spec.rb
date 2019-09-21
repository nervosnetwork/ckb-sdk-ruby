RSpec.describe CKB::Types::DryRunResult do
  let(:dry_run_result_h) do
    {
      "cycles": "0xc"
    }
  end

  let(:dry_run_result) { CKB::Types::DryRunResult.from_h(dry_run_result_h) }

  it "from h" do
    expect(dry_run_result).to be_a(CKB::Types::DryRunResult)
    expect(dry_run_result.cycles).to eq dry_run_result_h[:cycles].hex
  end

  it "to_h" do
    expect(
      dry_run_result.to_h
    ).to eq dry_run_result_h
  end
end
