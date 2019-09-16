RSpec.describe CKB::Types::ChainInfo do
  let(:chain_info_h) do
    {
      "alerts": [
        {
            "id": "0x2a",
            "message": "An example alert message!",
            "notice_until": "0x24bcca57c00",
            "priority": "0x1"
        }
      ],
      "chain": "main",
      "difficulty": "0x7a1200",
      "epoch": "0x1",
      "is_initial_block_download": true,
      "median_time": "0x5cd2b105"
    }
  end

  let(:chain_info) { CKB::Types::ChainInfo::from_h(chain_info_h) }

  it "from h" do
    expect(chain_info).to be_a(CKB::Types::ChainInfo)
    expect(chain_info.alerts).to all(be_a(CKB::Types::AlertMessage))
    %i(difficulty epoch median_time).each do |key|
      expect(chain_info.public_send(key)).to eq chain_info_h[key].hex
    end
  end

  it "to_h" do
    expect(
      chain_info.to_h
    ).to eq chain_info_h
  end
end
