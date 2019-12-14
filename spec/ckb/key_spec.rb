# frozen_string_literal: true

RSpec.describe CKB::Key do
  let(:privkey) { ENV["BOB_PRIVATE_KEY"] }
  let(:pubkey) { "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01" }
  let(:privkey_bin) { Utils.hex_to_bin(privkey) }
  let(:pubkey_bin) { Utils.hex_to_bin(pubkey) }
  let(:pubkey_blake160) { "0x36c329ed630d6ce750712a477543672adab57f4c" }
  let(:pubkey_blake160_bin) { Utils.hex_to_bin(pubkey_blake160) }
  let(:prefix) { "ckt" }

  let(:key) { CKB::Key.new(privkey) }

  it "pubkey" do
    expect(key.pubkey).to eq pubkey
  end

  describe "Out-of-bound Privkey" do
    let(:privkey) { "0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141" }

    it "raise ArgumentError on out-of-bound privkey" do
      random = double
      allow(random).to receive(:random_bytes).and_return(
        CKB::Utils.hex_to_bin(privkey),
        CKB::Utils.hex_to_bin("0x#{(privkey.to_i(16) - 1).to_s(16)}")
      )
      stub_const("SecureRandom", random)

      expect(CKB::Key.random_private_key.to_i(16)).to eq(privkey.to_i(16) - 1)
    end
  end

  context "sign message" do
    let(:msg) { "0x95e919c41e1ae7593730097e9bb1185787b046ae9f47b4a10ff4e22f9c3e3eab" }

    context "sign" do
      let(:expect_result) { "0x304402201e94db61cff452639cf7dd991cf0c856923dcf74af24b6f575b91479ad2c8ef402200769812d1cf1fd1a15d2f6cb9ef3d91260ef27e65e1f9be399887e9a54477863" }

      it "success" do
        expect(key.sign(msg)).to eq expect_result
      end
    end

    context "sign recoverable" do
      let(:expect_result) { "0x1e94db61cff452639cf7dd991cf0c856923dcf74af24b6f575b91479ad2c8ef40769812d1cf1fd1a15d2f6cb9ef3d91260ef27e65e1f9be399887e9a5447786301" }

      it "success" do
        expect(key.sign_recoverable(msg)).to eq expect_result
      end
    end
  end
end
