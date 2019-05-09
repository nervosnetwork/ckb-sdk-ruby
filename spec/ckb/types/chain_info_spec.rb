RSpec.describe CKB::Types::ChainInfo do
  let(:chain_info_h) do
    {
      "is_initial_block_download": false,
      "epoch": "0",
      "difficulty": "0x100",
      "median_time": "1557287480008",
      "chain": "ckb_dev",
      "warnings": ""
   }
  end

  it "from h" do
    chain_info = CKB::Types::ChainInfo::from_h(chain_info_h)
    expect(chain_info).to be_a(CKB::Types::ChainInfo)
  end
end
