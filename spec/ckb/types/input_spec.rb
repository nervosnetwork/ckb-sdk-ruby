RSpec.describe CKB::Types::Input do
  let(:input_h) do
    {
      "previous_output": {
          "index": "0xffffffff",
          "tx_hash": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      "since": "0x400"
    }
  end

  let(:input) { CKB::Types::Input.from_h(input_h) }

  it "from_h" do
    expect(input).to be_a(CKB::Types::Input)
    expect(input.previous_output).to be_a(CKB::Types::OutPoint)
    expect(input.since).to eq input_h[:since].hex
  end

  it "to_h" do
    expect(
      input.to_h
    ).to eq input_h
  end
end
