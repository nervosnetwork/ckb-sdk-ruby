# frozen_string_literal: true

RSpec.describe CKB::Types::Transaction do
  let(:tx_to_sign_hash) do
    { version: "0x0",
      cell_deps: [{ out_point: { tx_hash: "0xe7d5ddd093bcc5909a6f441882e58906062eaf66a6ac1bcf7d7411931bc9ab72", index: "0x0" },
                    dep_type: "dep_group" }],
      header_deps: [],
      inputs: [{ previous_output: { tx_hash: "0x650b8f3fcb2627b5500c308a9b0485b806e256886c36d641517eec53707bbcf9", index: "0x0" },
                 since: "0x0" }],
      outputs: [{ capacity: "0x174876e800",
                  lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                          args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                          hash_type: "type" },
                  type: nil },
                { capacity: "0x182ca202c9",
                  lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                          args: "0x3954acece65096bfa81258983ddb83915fc56bd8",
                          hash_type: "type" },
                  type: nil }],
      outputs_data: %w[0x 0x],
      witnesses: ["0x"] }
  end

  it "sign" do
    tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
    key = CKB::Key.new("0x845b781a1a094057b972714a2b09b85de4fc2eb205351c3e5179aabd264f3805")
    tx_hash = "0x993e6e629be2f016bf72becaa9ad4b39f7fdd72357c9341335783f451010b94e"
    signed_tx = tx_to_sign.sign(key, tx_hash)

    expect(signed_tx.to_h[:hash]).to eq(tx_hash)
    expect(signed_tx.to_h[:witnesses]).to eq(["0xf198c795adfc5aead05ad0ac9d979519b0a707e7987c5addb3a6be42669af7f86e3a76a3ce8c770a92915e2d5a0212b3417db1c2152f2107ee7683601a4ecb5001"])
  end

  context "multiple inputs sign" do
    let(:tx_to_sign_hash) do
      { version: "0x0",
        cell_deps: [{ out_point: { tx_hash: "0xe7d5ddd093bcc5909a6f441882e58906062eaf66a6ac1bcf7d7411931bc9ab72", index: "0x0" },
                      dep_type: "dep_group" }],
        header_deps: [],
        inputs: [{ previous_output: { tx_hash: "0xa31b9b8d105c62d69b7fbfc09bd700f3a1d6659232ffcfaa12a048ee5d7b7f2d", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xec5e63e19ec0161092ba78a841e9ead5deb30e56c2d98752ed974f2f2b4aeff2", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0x5ad2600cb884572f9d8f568822c0447f6f49eb63b53257c20d0d8559276bf4e2", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xf21e34224e90c1ab47f42e2977ea455445d22ba3aaeb4bd2fcb2075704f330ff", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xc8212696d516c63bced000d3008c4a8c27c72c03f4becb40f0bf24a31063271f", index: "0x0" },
                   since: "0x0" }],
        outputs: [{ capacity: "0xe8d4a51000",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                            hash_type: "type" },
                    type: nil },
                  { capacity: "0x47345dea3",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x3954acece65096bfa81258983ddb83915fc56bd8",
                            hash_type: "type" },
                    type: nil }],
        outputs_data: %w[0x 0x],
        witnesses: %w[0x 0x 0x 0x 0x] }
    end

    let(:tx_hash) { "0x03aea57404a99c685b098b7ee96469f0c5db57fa49aaef27cf7c080960da4b19" }

    let(:private_key) { "0x845b781a1a094057b972714a2b09b85de4fc2eb205351c3e5179aabd264f3805" }
    let(:key) { CKB::Key.new(private_key) }

    it "sign" do
      tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
      signed_tx = tx_to_sign.sign(key, tx_hash)

      expect(signed_tx.hash).to eq tx_hash
      expect(signed_tx.witnesses).to eq(%w[0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801 0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801 0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801 0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801 0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801])
    end
  end

  context "generate tx_hash" do
    let(:specific_tx_h) do
      { version: "0x0",
        cell_deps: [],
        header_deps: [],
        inputs: [{ previous_output: { tx_hash: "0x0000000000000000000000000000000000000000000000000000000000000000", index: "0xffffffff" },
                   since: "0xa" }],
        outputs: [{ capacity: "0x2ca7071b9e",
                    lock: { code_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
                            args: "0x",
                            hash_type: "type" },
                    type: nil }],
        outputs_data: ["0x"],
        witnesses: ["0x490000001000000030000000310000009bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce801140000003954acece65096bfa81258983ddb83915fc56bd8"],
        hash: "0x1c9e75323c160a52e18b8e7deaa09b31af600e4e942c7fa4934059a8f4a64d61" }
    end

    let(:one_cell_dep_tx_h) do
      { version: "0x0",
        cell_deps: [{ out_point: { tx_hash: "0xe7d5ddd093bcc5909a6f441882e58906062eaf66a6ac1bcf7d7411931bc9ab72", index: "0x0" },
                      dep_type: "dep_group" }],
        header_deps: [],
        inputs: [{ previous_output: { tx_hash: "0xa31b9b8d105c62d69b7fbfc09bd700f3a1d6659232ffcfaa12a048ee5d7b7f2d", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xec5e63e19ec0161092ba78a841e9ead5deb30e56c2d98752ed974f2f2b4aeff2", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0x5ad2600cb884572f9d8f568822c0447f6f49eb63b53257c20d0d8559276bf4e2", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xf21e34224e90c1ab47f42e2977ea455445d22ba3aaeb4bd2fcb2075704f330ff", index: "0x0" },
                   since: "0x0" },
                 { previous_output: { tx_hash: "0xc8212696d516c63bced000d3008c4a8c27c72c03f4becb40f0bf24a31063271f", index: "0x0" },
                   since: "0x0" }],
        outputs: [{ capacity: "0xe8d4a51000",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                            hash_type: "type" },
                    type: nil },
                  { capacity: "0x47345dea3",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x3954acece65096bfa81258983ddb83915fc56bd8",
                            hash_type: "type" },
                    type: nil }],
        outputs_data: %w[0x 0x],
        witnesses: %w[0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801
                      0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801
                      0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801
                      0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801
                      0xc5fb0574026cb74a8633bc2c67a32db701025ea5e3f4438c713daaa31539183d719a079a06e426036fc95d5ac97bcde84374a4b7002480d63f1bfc7dc5ee0d4801],
        hash: "0x03aea57404a99c685b098b7ee96469f0c5db57fa49aaef27cf7c080960da4b19" }
    end

    let(:multiple_cell_dep_tx_h) do
      { version: "0x0",
        cell_deps: [{ out_point: { tx_hash: "0xe7d5ddd093bcc5909a6f441882e58906062eaf66a6ac1bcf7d7411931bc9ab72", index: "0x0" },
                      dep_type: "dep_group" },
                    { out_point: { tx_hash: "0x50b9240d466800a6d0b2d07e10151b3a48f44c801a0f7f22e4e033419bd69b8e", index: "0x2" },
                      dep_type: "code" }],
        header_deps: [],
        inputs: [{ previous_output: { tx_hash: "0x3c515d38292bff5068eeddc94fa4aaea0f60f78a9c565ea3fb5835c8c395febf", index: "0x0" },
                   since: "0x0" }],
        outputs: [{ capacity: "0x9502f9000",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                            hash_type: "type" },
                    type: { code_hash: "0x88af2314293c7799a11a8ce3b551fb632d5ffa21b42d04326b051f580ca55f6a",
                            args: "0x",
                            hash_type: "data" } },
                  { capacity: "0xdf8475800",
                    lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                            args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                            hash_type: "type" },
                    type: nil }],
        outputs_data: %w[0x 0x],
        witnesses: ["0x7da70e8d0d529afb5f9193a5063463a757c305a4af0e882f6dbacc7cbe74096f1b14aabac84990e7902f28f40e2c8dd70f8dd06a600185c4e89090c25a7bf61700"],
        hash: "0xb4d2204035bf8df2ecec1ef9b632b5fc91a245555a96eb0812ed0b29b3f4039a" }
    end

    let(:has_type_script_tx_h) do
      { version: "0x0",
                       cell_deps: [{ out_point: { tx_hash: "0xe7d5ddd093bcc5909a6f441882e58906062eaf66a6ac1bcf7d7411931bc9ab72", index: "0x0" },
                                     dep_type: "dep_group" },
                                   { out_point: { tx_hash: "0x50b9240d466800a6d0b2d07e10151b3a48f44c801a0f7f22e4e033419bd69b8e", index: "0x2" },
                                     dep_type: "code" }],
                       header_deps: [],
                       inputs: [{ previous_output: { tx_hash: "0x3c515d38292bff5068eeddc94fa4aaea0f60f78a9c565ea3fb5835c8c395febf", index: "0x0" },
                                  since: "0x0" }],
                       outputs: [{ capacity: "0x9502f9000",
                                   lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                                           args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                                           hash_type: "type" },
                                   type: { code_hash: "0x88af2314293c7799a11a8ce3b551fb632d5ffa21b42d04326b051f580ca55f6a",
                                           args: "0x",
                                           hash_type: "data" } },
                                 { capacity: "0xdf8475800",
                                   lock: { code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                                           args: "0x59a27ef3ba84f061517d13f42cf44ed020610061",
                                           hash_type: "type" },
                                   type: nil }],
                       outputs_data: %w[0x 0x],
                       witnesses: ["0x7da70e8d0d529afb5f9193a5063463a757c305a4af0e882f6dbacc7cbe74096f1b14aabac84990e7902f28f40e2c8dd70f8dd06a600185c4e89090c25a7bf61700"],
                       hash: "0xb4d2204035bf8df2ecec1ef9b632b5fc91a245555a96eb0812ed0b29b3f4039a" }
    end

    it "should build correct hash for specific transaction" do
      tx = CKB::Types::Transaction.from_h(specific_tx_h)

      expect(
        tx.compute_hash
      ).to eq tx.hash
    end

    it "should build correct hash when tx has one cell_deps" do
      tx = CKB::Types::Transaction.from_h(one_cell_dep_tx_h)

      expect(
        tx.compute_hash
      ).to eq tx.hash
    end

    it "should build correct hash when tx has multiple cell_deps" do
      tx = CKB::Types::Transaction.from_h(multiple_cell_dep_tx_h)

      expect(
        tx.compute_hash
      ).to eq tx.hash
    end

    it "should build correct hash when has type script" do
      tx = CKB::Types::Transaction.from_h(has_type_script_tx_h)

      expect(
        tx.compute_hash
      ).to eq tx.hash
    end

    context "compared with rpc result" do
      before do
        skip "not call rpc" if ENV["SKIP_RPC_TESTS"]
      end

      let(:api) { CKB::API.new }

      it "should build correct hash for specific transaction" do
        tx = CKB::Types::Transaction.from_h(specific_tx_h)

        expect(
          tx.compute_hash
        ).to eq api.compute_transaction_hash(tx)
      end

      it "should build correct hash when tx has one cell_deps" do
        tx = CKB::Types::Transaction.from_h(one_cell_dep_tx_h)

        expect(
          tx.compute_hash
        ).to eq api.compute_transaction_hash(tx)
      end

      it "should build correct hash when tx has multiple cell_deps" do
        tx = CKB::Types::Transaction.from_h(multiple_cell_dep_tx_h)

        expect(
          tx.compute_hash
        ).to eq api.compute_transaction_hash(tx)
      end

      it "should build correct hash when has type script" do
        tx = CKB::Types::Transaction.from_h(has_type_script_tx_h)

        expect(
          tx.compute_hash
        ).to eq api.compute_transaction_hash(tx)
      end
    end
  end
end
