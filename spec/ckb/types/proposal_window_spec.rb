RSpec.describe CKB::Types::ProposalWindow do
  let(:proposal_window_h) do
    {
      closest: "0x2",
      farthest: "0xa"
    }
  end

  let(:proposal_window) { CKB::Types::ProposalWindow.from_h(proposal_window_h) }

  it "from h" do
    expect(proposal_window).to be_a(CKB::Types::ProposalWindow)
    proposal_window_h.each do |key, value|
      expect(proposal_window.public_send(key)).to eq value.hex
    end
  end

  it "to_h" do
    expect(
      proposal_window.to_h
    ).to eq proposal_window_h
  end
end
