RSpec.describe CKB::Utils do
  Utils = CKB::Utils

  let(:privkey) { ENV["BOB_PRIVATE_KEY"] }
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

  context "to_int" do
    it "using integer" do
      expect(
        Utils.to_int(10)
      ).to eq 10
    end

    it "using hex string" do
      expect(
        Utils.to_int("0x10")
      ).to eq 16
    end

    it "empty string" do
      expect {
        Utils.to_int("")
      }.to raise_error "Can't convert to int!"
    end
  end

  context "to_hex" do
    it "using integer" do
      expect(
        Utils.to_hex(10)
      ).to eq "0xa"
    end

    it "using hex string" do
      expect(
        Utils.to_hex("0x10")
      ).to eq "0x10"
    end

    it "using string without 0x" do
      expect {
        Utils.to_hex("10")
      }.to raise_error "Can't convert to hex string!"
    end
  end

  context "sudt amount" do
    it "should perse sudt amount correctly" do
      sudt_amount = 10_0000
      output_data = Utils.generate_sudt_amount(sudt_amount)

      expect(Utils.sudt_amount!(output_data)).to eq sudt_amount
    end

    it "should raise RuntimeError when amount bytesize is less than 16" do
      expect {
        Utils.sudt_amount!("0x03")
      }.to raise_error("Invalid sUDT amount")
    end

    it "should return 0 when output data is empty" do
      expect(Utils.sudt_amount!("0x")).to eq 0
    end

    it "should generate sudt amount output data correctly" do
      output_data = "0x00e1f505000000000000000000000000"
      expect(Utils.generate_sudt_amount(1_0000_0000)).to eq output_data
    end
  end
end
