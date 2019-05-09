RSpec.describe CKB::Types::PeerState do
  let(:peer_state_h) do
    {
      "last_updated": "1557289448237",
      "blocks_in_flight": "86",
      "peer": "1"
   }
  end

  it "from h" do
    peer_state = CKB::Types::PeerState.from_h(peer_state_h)
    expect(peer_state).to be_a(CKB::Types::PeerState)
  end
end
