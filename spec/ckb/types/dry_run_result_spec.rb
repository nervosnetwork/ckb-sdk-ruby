RSpec.describe CKB::Types::DryRunResult do
  let(:dry_run_result_h) do
    {
      "cycles": "0"
    }
  end

  it "from h" do
    dry_run_result = CKB::Types::DryRunResult.from_h(dry_run_result_h)
    expect(dry_run_result).to be_a(CKB::Types::DryRunResult)
  end
end
