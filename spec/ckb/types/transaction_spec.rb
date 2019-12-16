# frozen_string_literal: true
RSpec.describe CKB::Types::Transaction do
  let(:private_key) { ENV["BOB_PRIVATE_KEY"] }
  let(:key) { CKB::Key.new(private_key) }

  let(:tx_to_sign_hash) do
    {
      "version": "0x0",
      "cell_deps": [
        {
          "out_point": {
            "tx_hash": "0xace5ea83c478bb866edf122ff862085789158f5cbff155b7bb5f13058555b708",
            "index": "0x0"
          },
          "dep_type": "dep_group"
        }
      ],
      "header_deps": [],
      "inputs": [
        {
          "previous_output": {
            "tx_hash": "0x3ac0a667dc308a78f38c75cbeedfdea9247bbd67e727e1c153a4aa1a2afb28d8",
            "index": "0x0"
          },
          "since": "0x0"
        }
      ],
      "outputs": [
        {
          "capacity": "0x174876e800",
          "lock": {
            "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
            "args": "0xe2193df51d78411601796b35b17b4f8f2cd85bd0",
            "hash_type": "type"
          },
          "type": nil
        },
        {
          "capacity": "0x123057115561",
          "lock": {
            "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
            "args": "0x36c329ed630d6ce750712a477543672adab57f4c",
            "hash_type": "type"
          },
          "type": nil
        }
      ],
      "outputs_data": [
        "0x",
        "0x"
      ],
      "witnesses": [CKB::Types::Witness.new],
      "hash": "0x8457b932a9a3cd0bedd3eebad473cf7fd1f59cd5f96f80a637271a6901e4a0da"
    }
  end

  let(:tx_to_sign_hash_use_data_hash) do
    { version: "0x0",
      cell_deps: [{ out_point: { tx_hash: "0xa76801d09a0eabbfa545f1577084b6f3bafb0b6250e7f5c89efcfd4e3499fb55", index: "0x1" },
                    dep_type: "code" }],
      header_deps: [],
      inputs: [{ previous_output: { tx_hash: "0xa80a8e01d45b10e1cbc8a2557c62ba40edbdc36cd63a31fc717006ca7b157b50", index: "0x0" },
                 since: "0x0" }],
      outputs: [{ capacity: "0x174876e800",
                  lock: { code_hash: "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
                          args: "0xe2193df51d78411601796b35b17b4f8f2cd85bd0",
                          hash_type: "data" },
                  type: nil },
                { capacity: "0x474dec26800",
                  lock: { code_hash: "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
                          args: "0x36c329ed630d6ce750712a477543672adab57f4c",
                          hash_type: "data" },
                  type: nil }],
      outputs_data: %w[0x 0x],
      witnesses: [CKB::Types::Witness.new] }
  end

  it "sign" do
    tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
    tx_hash = "0x8457b932a9a3cd0bedd3eebad473cf7fd1f59cd5f96f80a637271a6901e4a0da"
    signed_tx = tx_to_sign.sign(key)

    expect(signed_tx.to_h[:hash]).to eq(tx_hash)
    expect(signed_tx.to_h[:witnesses]).to eq(["0x55000000100000005500000055000000410000007c1fae2bc44369f8bca4d7532f7c7adaf978f4dbde86d3c97bca39e05c4354b17bef1b2184a99fe405e7b1ed8c70d9c314d9a6d7d46008c8b08a1a3dbb09190d01"])
  end

  it "sign with data hash" do
    tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash_use_data_hash)
    tx_hash = tx_to_sign.compute_hash
    signed_tx = tx_to_sign.sign(key)

    expect(signed_tx.to_h[:hash]).to eq(tx_hash)
    expect(signed_tx.to_h[:witnesses]).to eq(["0x55000000100000005500000055000000410000007a360306c20f1f0081d27feff5c59fb9b4307b25876543848010614fb78ea21d165f48f67ae3357eeafbad2033b1e53cd737d4e670de60e1081d514b1e05cf5100"])
  end

  context "multiple inputs sign" do
    let(:tx_to_sign_hash) do
      {
        "version": "0x0",
        "cell_deps": [
          {
            "out_point": {
              "tx_hash": "0xace5ea83c478bb866edf122ff862085789158f5cbff155b7bb5f13058555b708",
              "index": "0x0"
            },
            "dep_type": "dep_group"
          }
        ],
        "header_deps": [],
        "inputs": [
          {
            "previous_output": {
              "tx_hash": "0x7f6e63319c3148eaea767cdf800d76bba4824d3a85c88e39221901c94b8255f5",
              "index": "0x0"
            },
            "since": "0x0"
          },
          {
            "previous_output": {
              "tx_hash": "0xd7c23e7ffbbb70b5bf6e5d15c9c39bb7e11a16e272df4509191112d19a358415",
              "index": "0x0"
            },
            "since": "0x0"
          },
          {
            "previous_output": {
              "tx_hash": "0xa674ff0b7daa0d6708f518f74122f68af0e1a67cbd5736e8b6c23c7ed289e01d",
              "index": "0x0"
            },
            "since": "0x0"
          },
          {
            "previous_output": {
              "tx_hash": "0x33045ca3a14071ef73ff70d0b989f6463913d74a825b31a28a9cbdd895edcc1f",
              "index": "0x0"
            },
            "since": "0x0"
          },
          {
            "previous_output": {
              "tx_hash": "0x6b59838ddfe9551299a83061935ba9dbee9920c26ab526319bbe26a67fc85cc4",
              "index": "0x0"
            },
            "since": "0x0"
          }
        ],
        "outputs": [
          {
            "capacity": "0x5af3107a4000",
            "lock": {
              "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
              "args": "0xe2193df51d78411601796b35b17b4f8f2cd85bd0",
              "hash_type": "type"
            },
            "type": nil
          },
          {
            "capacity": "0x7306fb4b6f",
            "lock": {
              "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
              "args": "0x36c329ed630d6ce750712a477543672adab57f4c",
              "hash_type": "type"
            },
            "type": nil
          }
        ],
        "outputs_data": [
          "0x",
          "0x"
        ],
        "witnesses": [
          CKB::Types::Witness.new,
          CKB::Types::Witness.new,
          CKB::Types::Witness.new,
          CKB::Types::Witness.new,
          CKB::Types::Witness.new
        ]
      }
    end

    let(:tx_hash) { "0x11a67b2de5629a39a1514b39c27500bad8a52cb8ff604ddb50f0f8fc044a5448" }

    it "sign" do
      tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
      signed_tx = tx_to_sign.sign(key)
      expect(signed_tx.hash).to eq tx_hash
      expect(signed_tx.to_raw_transaction_h[:witnesses]).to eq([
        "0x550000001000000055000000550000004100000042ab4a61dec16c0dce4bdec692eb4f9814af4f50ce929cf0b88c4282e2970ce14ee827c7707676f50da13108e8ef23aed9043d7b64f78e216f2bd750888ecbae01",
        "0x10000000100000001000000010000000",
        "0x10000000100000001000000010000000",
        "0x10000000100000001000000010000000",
        "0x10000000100000001000000010000000"
      ])
    end

    let(:tx_to_sign_hash_use_data_hash) do
      { version: "0x0",
        cell_deps: [{ out_point: { tx_hash: "0xa76801d09a0eabbfa545f1577084b6f3bafb0b6250e7f5c89efcfd4e3499fb55", index: "0x1" },
                      dep_type: "code" }],
        header_deps: [],
        inputs: [{ previous_output: { tx_hash: "0x91fcfd61f420c1090aeded6b6d91d5920a279fe53ec34353afccc59264eeddd4", index: "0x0" },
                   since: "0x71" },
                 { previous_output: { tx_hash: "0x00000000000000000000000000004e4552564f5344414f494e50555430303031", index: "0x0" },
                   since: "0x0" }
        ],
        outputs: [{ capacity: "0x9184efca682",
                    lock: { code_hash: "0xf1951123466e4479842387a66fabfd6b65fc87fd84ae8e6cd3053edb27fff2fd",
                            args: "0x36c329ed630d6ce750712a477543672adab57f4c",
                            hash_type: "data" },
                    type: nil }],
        outputs_data: %w[0x],
        witnesses: [CKB::Types::Witness.new(lock: "0x4107bd23eedb9f2a2a749108f6bb9720d745d50f044cc4814bafe189a01fe6fb", input_type: "0x99caa8d7efdaab11c2bb7e45f4f385d0405f0fa2e8d3ba48496c28a2443e607d", output_type: "0xa6d5e23a77f4d7940aeb88764eebf8146185138641ac43b233e1c9b3daa170fa"), "0x"]}
    end

    it "sign2" do
      tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash_use_data_hash)
      tx_hash = tx_to_sign.compute_hash
      signed_tx = tx_to_sign.sign(key)

      expect(signed_tx.to_h[:hash]).to eq(tx_hash)
      expect(signed_tx.to_h[:witnesses]).to eq(%w(0x9d00000010000000550000007900000041000000d896d67ddda97ab2d15cd13098b40e4a2b6d6c66ad465d987df9a28b0a038f4a18dbebbc702a1a0b2056aa9e4290a3640a4d73dd1f6483e6f8e0cd2784b4a78b002000000099caa8d7efdaab11c2bb7e45f4f385d0405f0fa2e8d3ba48496c28a2443e607d20000000a6d5e23a77f4d7940aeb88764eebf8146185138641ac43b233e1c9b3daa170fa 0x))
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
