RSpec.describe CKB::Types::BlockReward do
  let(:block_reward_h) do
    {
      "primary": "0x102b36211d",
      "proposal_reward": "0x0",
      "secondary": "0x2ca110a5",
      "total": "0x1057d731c2",
      "tx_fee": "0x0"
    }
  end

  let(:block_reward) { CKB::Types::BlockReward.from_h(block_reward_h) }

  it "from h" do
    expect(block_reward).to be_a(CKB::Types::BlockReward)
    block_reward_h.keys.each do |key|
      expect(block_reward.public_send(key)).to eq block_reward_h[key].hex
    end
  end

  it "to_h" do
    expect(
      block_reward.to_h
    ).to eq block_reward_h
  end
end
