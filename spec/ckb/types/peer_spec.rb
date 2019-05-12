RSpec.describe CKB::Types::Peer do
  let(:peer_h) do
    {
      "addresses": [
          {
              "address": "/ip4/192.168.0.3/tcp/8115",
              "score": "1"
          }
      ],
      "is_outbound": true,
      "node_id": "QmaaaLB4uPyDpZwTQGhV63zuYrKm4reyN2tF1j2ain4oE7",
      "version": "unknown"
    }
  end

  it "from h" do
    peer = CKB::Types::Peer::from_h(peer_h)
    expect(peer).to be_a(CKB::Types::Peer)
  end
end
