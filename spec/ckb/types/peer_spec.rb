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
      "connected_duration": "0x2f",
      "is_outbound": nil,
      "last_ping_duration": "0x1a",
      "node_id": "QmTRHCdrRtgUzYLNCin69zEvPvLYdxUZLLfLYyHVY3DZAS",
      "protocols": [
          {
              "id": "0x4",
              "version": "0.0.1"
          },
          {
              "id": "0x2",
              "version": "0.0.1"
          },
          {
              "id": "0x1",
              "version": "0.0.1"
          },
          {
              "id": "0x64",
              "version": "1"
          },
          {
              "id": "0x6e",
              "version": "1"
          },
          {
              "id": "0x66",
              "version": "1"
          },
          {
              "id": "0x65",
              "version": "1"
          },
          {
              "id": "0x0",
              "version": "0.0.1"
          }
      ],
      "sync_state": {
          "best_known_header_hash": nil,
          "best_known_header_number": nil,
          "can_fetch_count": "0x80",
          "inflight_count": "0xa",
          "last_common_header_hash": nil,
          "last_common_header_number": nil,
          "unknown_header_list_size": "0x20"
      },
      "version": "0.0.0",
    }
  end

  let(:peer) { CKB::Types::Peer::from_h(peer_h) }

  it "from h" do
    expect(peer).to be_a(CKB::Types::Peer)
    expect(peer.addresses).to all(be_a(CKB::Types::AddressInfo))
    expect(peer.sync_state).to be_a(CKB::Types::PeerSyncState)
  end

  it "to_h" do
    expect(
      peer.to_h
    ).to eq peer_h
  end
end
