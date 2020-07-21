RSpec.describe CKB::Types::Script do
  let(:script) do
    code_hash = CKB::Blake2b.hexdigest(
      CKB::Utils.hex_to_bin(
        "0x1400000000000e00100000000c000800000004000e0000000c00000014000000740100000000000000000600080004000600000004000000580100007f454c460201010000000000000000000200f3000100000078000100000000004000000000000000980000000000000005000000400038000100400003000200010000000500000000000000000000000000010000000000000001000000000082000000000000008200000000000000001000000000000001459308d00573000000002e7368737472746162002e74657874000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000010000000600000000000000780001000000000078000000000000000a000000000000000000000000000000020000000000000000000000000000000100000003000000000000000000000000000000000000008200000000000000110000000000000000000000000000000100000000000000000000000000000000000000"
      )
    )
    CKB::Types::Script.new(
      code_hash: code_hash,
      args: "0x"
    )
  end

  let(:code_hash) { "0xc00073200d2b2f4ad816a8d04bb2431ce0d3ebd49141b086eda4ab4e06bc3a21" }

  context "to_hash" do
    before do
      skip if ENV["SKIP_RPC_TESTS"]
    end

    let(:api) { CKB::API.new }

    it "should build correct hash when args is empty " do
      expect(
        script.compute_hash
      ).to eq api._compute_script_hash(script)
    end

    it "should build correct hash when there is only one arg" do
      script = CKB::Types::Script.new(
        code_hash: code_hash,
        args: "0x3954acece65096bfa81258983ddb83915fc56bd8"
      )

      expect(
        script.compute_hash
      ).to eq api._compute_script_hash(script)
    end

    it "should build correct hash when args more than one" do
      script = CKB::Types::Script.new(
        code_hash: code_hash,
        args: "0x3954acece65096bfa81258983ddb83915fc56bd83954acece65096bfa81258983ddb83915fc56bd8"
      )
      expect(
        script.compute_hash
      ).to eq api._compute_script_hash(script)
    end
  end

  context "calculate bytesize" do
    let(:code_hash) { "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08" }
    let(:args) { "0x36c329ed630d6ce750712a477543672adab57f4c" }

    let(:lock_script) do
      CKB::Types::Script.new(
        code_hash: code_hash,
        args: args
      )
    end
    let(:min_capacity) { 53 }

    it "success" do
      expect(
        lock_script.calculate_bytesize
      ).to eq (min_capacity)
    end
  end

  context "attributes validation" do
    it "should raise EmptyCodeHashError when code hash is empty string" do
      expect {
        CKB::Types::Script.new(code_hash: "", args: "", hash_type: "type")
      }.to raise_error(CKB::Types::Script::EmptyCodeHashError, "CodeHash cannot be empty")
    end

    it "should raise EmptyCodeHashError when code hash is nil" do
      expect {
        CKB::Types::Script.new(code_hash: nil, args: "", hash_type: "type")
      }.to raise_error(CKB::Types::Script::EmptyCodeHashError, "CodeHash cannot be empty")
    end

    it "should raise InvalidHexStringError when code hash is an invalid hex string" do
      expect {
        CKB::Types::Script.new(code_hash: "0x9", args: "", hash_type: "type")
      }.to raise_error(CKB::Types::Script::InvalidHexStringError, "CodeHash is an invalid hex string")
    end

    it "should raise InvalidCodeHashSizeError when code hash size is less than 32" do
      expect {
        CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cc", args: "", hash_type: "type")
      }.to raise_error(CKB::Types::Script::InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32")
    end

    it "should raise InvalidHexStringError when args is an invalid hex string" do
      expect {
        CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0x1", hash_type: "type")
      }.to raise_error(CKB::Types::Script::InvalidHexStringError, "Args is an invalid hex string")
    end
  end
end
