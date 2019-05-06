RSpec.describe CKB::Utils do
  Utils = CKB::Utils

  let(:privkey) { "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3" }
  let(:pubkey) { "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01" }
  let(:address) { "0xbc374983430db3686ab181138bb510cb8f83aa136d833ac18fc3e73a3ad54b8b" }
  let(:privkey_bin) { Utils.hex_to_bin(privkey) }
  let(:pubkey_bin) { Utils.hex_to_bin(pubkey) }
  let(:pubkey_blake160) { "0x36c329ed630d6ce750712a477543672adab57f4c" }
  let(:pubkey_blake160_bin) { Utils.hex_to_bin(pubkey_blake160) }
  let(:prefix) { "ckt" }
  let(:address) { "ckt1q9gry5zgxmpjnmtrp4kww5r39frh2sm89tdt2l6v234ygf" }

  it "valid hex string!" do
    expect(Utils.valid_hex_string?("0x1234")).to eq true
  end

  it "invalid hex string without prefix!" do
    expect(Utils.valid_hex_string?("1234")).to eq false
  end

  it "invalid hex string!" do
    expect(Utils.valid_hex_string?("0x12345")).to eq false
  end

  it "prefix hex to bin" do
    hex = "abcd12"
    prefix_hex = "0x#{hex}"
    expect(Utils.send(:hex_to_bin, prefix_hex)).to eq [hex].pack("H*")
  end

  it "bin to hex" do
    hex = "abcd12"
    bin = [hex].pack("H*")
    prefix_hex = "0x#{hex}"
    expect(Utils.bin_to_hex(bin)).to eq prefix_hex
  end
end
