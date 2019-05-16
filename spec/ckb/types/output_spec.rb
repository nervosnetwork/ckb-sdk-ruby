RSpec.describe CKB::Types::Output do
  let(:output) do
    CKB::Types::Output.new(
      capacity: "4500000000",
      data: "0x72796c6169",
      lock: CKB::Types::Script.new(
        args: [],
        code_hash: "0xb35557e7e9854206f7bc13e3c3a7fa4cf8892c84a09237fb0aab40aab3771eee",
      ),
      type: nil
    )
  end

  it "bytesize" do
    expect(
      output.calculate_bytesize
    ).to eq 45
  end
end
