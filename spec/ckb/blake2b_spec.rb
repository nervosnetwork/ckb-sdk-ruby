RSpec.describe CKB::Blake2b do
  let(:message) { "" }
  let(:message_digest) { "0x44f4c69744d5f8c55d642062949dcae49bc4e7ef43d388c5a12f42b5633d163e" }
  let(:message_digest_bytes) { CKB::Utils.hex_to_bin(message_digest) }

  it "digest" do
    blake2b = CKB::Blake2b.new
    blake2b.update(message)
    expect(blake2b.digest).to eq message_digest_bytes
  end

  it "hexdigest" do
    blake2b = CKB::Blake2b.new
    blake2b.update(message)
    expect(
      blake2b.hexdigest
    ).to eq message_digest
  end

  it "self.digest" do
    expect(
      CKB::Blake2b.digest(message)
    ).to eq message_digest_bytes
  end

  it "self.hexdigest" do
    expect(
      CKB::Blake2b.hexdigest(message)
    ).to eq message_digest
  end
end