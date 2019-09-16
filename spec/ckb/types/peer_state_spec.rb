RSpec.describe CKB::Types::PeerState do
  let(:peer_state_h) do
    {
      "blocks_in_flight": "0x56",
      "last_updated": "0x16a95af332d",
      "peer": "0x1"
   }
  end

  let(:peer_state) { CKB::Types::PeerState.from_h(peer_state_h) }

  it "from h" do
    expect(peer_state).to be_a(CKB::Types::PeerState)
    peer_state_h.keys.each do |key| 
      expect(peer_state.public_send(key)).to eq peer_state_h[key].hex
    end
  end

  it "to_h" do
    expect(
      peer_state.to_h
    ).to eq peer_state_h
  end
end
