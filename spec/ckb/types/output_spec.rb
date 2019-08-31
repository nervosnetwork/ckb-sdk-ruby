RSpec.describe CKB::Types::Output do
  let(:output) do
    CKB::Types::Output.new(
      capacity: "4500000000",
      lock: CKB::Types::Script.new(
        args: ["0x36c329ed630d6ce750712a477543672adab57f4c"],
        code_hash: "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
      )
    )
  end

  context "calculate bytesize" do
    it "default" do
      expect(
        output.calculate_bytesize("0x")
      ).to eq 61
    end

    it "with data" do
      expect(
        output.calculate_bytesize("0x1234")
      ).to eq 63
    end

    it "with type script" do
      type_script = CKB::Types::Script.new(
        args: [],
        code_hash: "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
      )
      output.instance_variable_set(:@type, type_script)

      expect(
        output.calculate_bytesize("0x")
      ).to eq (61 + 33)
    end
  end

  it "calculate min capacity" do
    expect(
      output.calculate_min_capacity("0x")
    ).to eq CKB::Utils.byte_to_shannon(61)
  end
end
