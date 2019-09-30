RSpec.describe CKB::Address do
  let(:privkey) { "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3" }
  let(:pubkey) { "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01" }
  let(:privkey_bin) { Utils.hex_to_bin(privkey) }
  let(:pubkey_bin) { Utils.hex_to_bin(pubkey) }
  let(:pubkey_blake160) { "0x36c329ed630d6ce750712a477543672adab57f4c" }
  let(:pubkey_blake160_bin) { Utils.hex_to_bin(pubkey_blake160) }
  let(:prefix) { "ckt" }
  let(:data_hash) { "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176" }
  let(:type_hash) { "0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2" }
  let(:pubkey_hash160) { "0xc8045f588e627a8381810923c61d0705d10b86d3" }
  let(:short_payload_blake160_address) { "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83" }
  let(:short_payload_blake160_address_with_invalid_format_type) { "ckt1qvqrdsefa43s6m882pcj53m4gdnj4k440axqdxkp8n" }
  let(:short_payload_blake160_address_with_invalid_code_hash_index) { "ckt1qypndsefa43s6m882pcj53m4gdnj4k440axq2jsln8" }
  let(:short_payload_hash160_address) { "ckt1qyquspzltz8xy75rsxqsjg7xr5rst5gtsmfsjh777d" }
  let(:full_payload_data_address) { "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5czshhac" }
  let(:full_payload_type_address) { "ckt1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5c02auef" }
  let(:full_payload_data_address_with_multiple_args) { "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhdh08sqwqw00mx3jv0v0stwqxhv4mhp8fjqwpmhuuzdgxrdmrtjj3uu6lc2crem3nj204af0" }
  let(:full_payload_type_address_with_multiple_args) { "ckt1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xl9h08sqwqw00mx3jv0v0stwqxhv4mhp8fjqwpmhuuzdgxrdmrtjj3uu6lc2crem3njluztad" }
  let(:multiple_args) { "0xdde7801c073dfb3464c7b1f05b806bb2bbb84e9901c1ddf9c135061b7635ca51e735fc2b03cee339" }

  context "from pubkey" do
    let(:addr) { CKB::Address.from_pubkey(pubkey) }

    it "pubkey blake160" do
      addr.blake160
      pubkey_blake160
      expect(
        addr.blake160
      ).to eq pubkey_blake160
    end

    it "generate short payload blake160 address" do
      expect(
        addr.to_s
      ).to eq short_payload_blake160_address
    end

    it "generate short payload hash160 address" do
      expect(
        CKB::Address.generate_short_payload_hash160_address(pubkey_hash160)
      ).to eq short_payload_hash160_address
    end

    it "generate full payload data address" do
      expect(
        CKB::Address.generate_full_payload_address(2, data_hash, pubkey_blake160)
      ).to eq full_payload_data_address
    end

    it "generate full payload data address should raise error when format_type is invalid" do
      expect {
        CKB::Address.generate_full_payload_address(3, data_hash, pubkey_blake160)
      }.to raise_error(CKB::Address::InvalidFormatTypeError)
    end

    it "generate full payload data address should raise error when args is not an hex string" do
      expect {
        CKB::Address.generate_full_payload_address(2, data_hash, pubkey_blake160[2..-1])
      }.to raise_error(CKB::Address::InvalidArgsTypeError)
    end

    it "generate full payload data address can accept empty arg" do
      expect {
        CKB::Address.generate_full_payload_address(2, data_hash, "0x")
      }.not_to raise_error
    end

    it "generate full payload type address" do
      expect(
        CKB::Address.generate_full_payload_address(4, type_hash, pubkey_blake160)
      ).to eq full_payload_type_address
    end

    it "generate full payload data address with multiple args" do
      expect(
        CKB::Address.generate_full_payload_address(2, data_hash, multiple_args)
      ).to eq full_payload_data_address_with_multiple_args
    end

    it "generate full payload type address with multiple args" do
      expect(
        CKB::Address.generate_full_payload_address(4, type_hash, multiple_args)
      ).to eq full_payload_type_address_with_multiple_args
    end

    it "parse short payload blake160 address" do
      expect(
        addr.parse(short_payload_blake160_address)
      ).to eq pubkey_blake160
    end

    it "parse short payload hash160 address" do
      expect(
        addr.parse(short_payload_hash160_address)
      ).to eq pubkey_hash160
    end

    it "parse full payload data address" do
      expect(
        addr.parse(full_payload_data_address)
      ).to eq ["0x02", data_hash, pubkey_blake160]
    end

    it "parse full payload type address" do
      expect(
        addr.parse(full_payload_type_address)
      ).to eq ["0x04", type_hash, pubkey_blake160]
    end

    it "parse full payload data address with multiple args" do
      expect(
        addr.parse(full_payload_data_address_with_multiple_args)
      ).to eq ["0x02", data_hash, multiple_args]
    end

    it "parse full payload type address with multiple args" do
      expect(
        addr.parse(full_payload_type_address_with_multiple_args)
      ).to eq ["0x04", type_hash, multiple_args]
    end
  end

  context "from pubkey hash" do
    let(:addr) { CKB::Address.new(pubkey_blake160) }

    it "generate short payload blake160 address" do
      expect(
        addr.to_s
      ).to eq short_payload_blake160_address
    end

    it "generate short payload hash160 address" do
      expect(
        CKB::Address.generate_short_payload_hash160_address(pubkey_hash160)
      ).to eq short_payload_hash160_address
    end

    it "generate full payload data address" do
      expect(
        CKB::Address.generate_full_payload_address("0x02", data_hash, pubkey_blake160)
      ).to eq full_payload_data_address
    end

    it "generate full payload type address" do
      expect(
        CKB::Address.generate_full_payload_address("0x04", type_hash, pubkey_blake160)
      ).to eq full_payload_type_address
    end

    it "generate full payload data address with multiple args" do
      expect(
        CKB::Address.generate_full_payload_address("0x02", data_hash, multiple_args)
      ).to eq full_payload_data_address_with_multiple_args
    end

    it "generate full payload type address with multiple args" do
      expect(
        CKB::Address.generate_full_payload_address("0x04", type_hash, multiple_args)
      ).to eq full_payload_type_address_with_multiple_args
    end

    it "parse short payload blake160 address" do
      expect(
        addr.parse(short_payload_blake160_address)
      ).to eq pubkey_blake160
    end

    it "parse short payload hash160 address" do
      expect(
        addr.parse(short_payload_hash160_address)
      ).to eq pubkey_hash160
    end

    it "parse full payload data address" do
      expect(
        addr.parse(full_payload_data_address)
      ).to eq ["0x02", data_hash, pubkey_blake160]
    end

    it "parse full payload type address" do
      expect(
        addr.parse(full_payload_type_address)
      ).to eq ["0x04", type_hash, pubkey_blake160]
    end

    it "parse full payload data address with multiple args" do
      expect(
        addr.parse(full_payload_data_address_with_multiple_args)
      ).to eq ["0x02", data_hash, multiple_args]
    end

    it "parse full payload type address with multiple args" do
      expect(
        addr.parse(full_payload_type_address_with_multiple_args)
      ).to eq ["0x04", type_hash, multiple_args]
    end
  end

  context "self.parse" do
    it "parse short payload blake160 address" do
      expect(
        CKB::Address.parse(short_payload_blake160_address)
      ).to eq pubkey_blake160
    end

    it "failed if mainnet mode" do
      expect {
        CKB::Address.parse(short_payload_blake160_address, mode: CKB::MODE::MAINNET)
      }.to raise_error(CKB::Address::InvalidPrefixError)
    end

    it "failed when format type is invalid" do
      expect {
        CKB::Address.parse(short_payload_blake160_address_with_invalid_format_type)
      }.to raise_error(CKB::Address::InvalidFormatTypeError)
    end

    it "failed when code hash index is invalid" do
      expect {
        CKB::Address.parse(short_payload_blake160_address_with_invalid_code_hash_index)
      }.to raise_error(CKB::Address::InvalidCodeHashIndexError)
    end

    it "eq to parse" do
      expect(
        CKB::Address.parse(short_payload_blake160_address)
      ).to eq CKB::Address.new(pubkey_blake160).parse(short_payload_blake160_address)
    end
  end
end
