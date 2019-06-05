RSpec.describe CKB::Address do
  let(:privkey) { "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3" }
  let(:pubkey) { "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01" }
  let(:privkey_bin) { Utils.hex_to_bin(privkey) }
  let(:pubkey_bin) { Utils.hex_to_bin(pubkey) }
  let(:pubkey_blake160) { "0x36c329ed630d6ce750712a477543672adab57f4c" }
  let(:pubkey_blake160_bin) { Utils.hex_to_bin(pubkey_blake160) }
  let(:prefix) { "ckt" }
  let(:address) { "ckt1q9gry5zgxmpjnmtrp4kww5r39frh2sm89tdt2l6v234ygf" }

  context "from pubkey" do
    let(:addr) { CKB::Address.from_pubkey(pubkey) }

    it "pubkey blake160" do
      addr.blake160
      pubkey_blake160
      expect(
        addr.blake160
      ).to eq pubkey_blake160
    end

    it "generate_address" do
      expect(
        addr.to_s
      ).to eq address
    end

    it "parse_address" do
      expect(
        addr.parse(address)
      ).to eq pubkey_blake160
    end
  end

  context "from pubkey hash" do
    let(:addr) { CKB::Address.new(pubkey_blake160) }

    it "generate_address" do
      expect(
        addr.to_s
      ).to eq address
    end

    it "parse_address" do
      expect(
        addr.parse(address)
      ).to eq pubkey_blake160
    end
  end

  context "self.parse" do
    it "success" do
      expect(
        CKB::Address.parse(address)
      ).to eq pubkey_blake160
    end

    it "failed if mainnet mode" do
      expect {
        CKB::Address.parse(address, mode: CKB::MODE::MAINNET)
      }.to raise_error(RuntimeError)
    end

    it "eq to parse" do
      expect(
        CKB::Address.parse(address)
      ).to eq CKB::Address.new(pubkey_blake160).parse(address)
    end
  end
end
