RSpec.describe CKB::Wallet do
  let(:privkey) { ENV["BOB_PRIVATE_KEY"]}
  let(:key) { CKB::Key.new(privkey) }
  let(:pubkey) { key.pubkey }
  let(:api) { nil }

  context "initialize" do
    it "Key" do
      wallet = CKB::Wallet.new(api, key)

      expect(wallet.key.privkey).to eq key.privkey
      expect(wallet.pubkey).to eq key.pubkey
    end

    it "pubkey" do
      wallet = CKB::Wallet.new(api, pubkey)

      expect(wallet.key).to be nil
      expect(wallet.pubkey).to eq pubkey
    end
  end

  it "self.from_hex" do
    wallet = CKB::Wallet.from_hex(api, privkey)

    expect(wallet.key.privkey).to eq privkey
  end

  context "convert_key" do
    let(:wallet) { CKB::Wallet.new(api, pubkey) }
    it "nil" do
      expect(
        wallet.send(:convert_key, nil)
      ).to be nil
    end

    it "Key" do
      expect(
        wallet.send(:convert_key, key)
      ).to be key
    end

    it "privkey" do
      expect(
        wallet.send(:convert_key, privkey)
      ).to be_a(CKB::Key)
    end
  end

  context "get_key" do
    context "key exists" do
      let(:wallet) { CKB::Wallet.new(api, key) }

      it "return @key" do
        the_key = wallet.send(:get_key, key)

        expect(the_key).to be wallet.key
      end
    end

    context "key not exists" do
      let(:wallet) { CKB::Wallet.new(api, pubkey) }

      it "nil" do
        expect {
          wallet.send(:get_key, nil)
        }.to raise_error(RuntimeError)
      end

      it "Key" do
        expect(
          wallet.send(:get_key, key)
        ).to eq key
      end

      it "privkey" do
        expect(
          wallet.send(:get_key, privkey)
        ).to be_a(CKB::Key)
      end
    end
  end
end