RSpec.describe CKB::Types::Peer do
  let(:peer_h) do
    {
      "addresses": [
        {
            "address": "/ip4/192.168.0.2/tcp/8112/p2p/QmTRHCdrRtgUzYLNCin69zEvPvLYdxUZLLfLYyHVY3DZAS",
            "score": "0xff"
        },
        {
            "address": "/ip4/0.0.0.0/tcp/8112/p2p/QmTRHCdrRtgUzYLNCin69zEvPvLYdxUZLLfLYyHVY3DZAS",
            "score": "0x1"
        }
      ],
      "is_outbound": nil,
      "node_id": "QmTRHCdrRtgUzYLNCin69zEvPvLYdxUZLLfLYyHVY3DZAS",
      "version": "0.0.0"
    }
  end

  let(:peer) { CKB::Types::Peer::from_h(peer_h) }

  it "from h" do
    expect(peer).to be_a(CKB::Types::Peer)
    expect(peer.addresses).to all(be_a(CKB::Types::AddressInfo))
  end

  it "to_h" do
    expect(
      peer.to_h
    ).to eq peer_h
  end
end
