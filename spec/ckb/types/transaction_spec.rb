RSpec.describe CKB::Types::Transaction do
  let(:tx_to_sign_hash) do
    {
      "version": "0",
      "cell_deps":[],
      "header_deps":[],
      "inputs": [
        {
          "args": [],
          "previous_output": {
            "block_hash": nil,
            "cell": {
              "tx_hash": "0xa80a8e01d45b10e1cbc8a2557c62ba40edbdc36cd63a31fc717006ca7b157b50",
              "index": "0"
            }
          },
          "since": "0"
        }
      ],
      "outputs": [
        {
          "capacity": "100000000000",
          "lock": {
            "code_hash": "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
            "args": [
              "0xe2193df51d78411601796b35b17b4f8f2cd85bd0"
            ]
          },
          "type": nil,
          "data": "0x"
        },
        {
          "capacity": "4900000000000",
          "lock": {
            "code_hash": "0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
            "args": [
              "0x36c329ed630d6ce750712a477543672adab57f4c"
            ]
          },
          "type": nil,
          "data": "0x"
        }
      ],
      "witnesses": [
        {
          data: []
        }
      ]
    }
  end

  it "sign" do
    tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
    key = CKB::Key.new("0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3")
    tx_hash = "0xac1bb95455cdfb89b6e977568744e09b6b80e08cab9477936a09c4ca07f5b8ab"
    signed_tx = tx_to_sign.sign(key, tx_hash)

    expect(signed_tx.to_h[:hash]).to eq(tx_hash)
    expect(signed_tx.to_h[:witnesses]).to eq([
      {
        data: [
          "0x2c643579e47045be050d3842ed9270151af8885e33954bddad0e53e81d1c2dbe2dc637877a8302110846ebc6a16d9148c106e25f945063ad1c4d4db2b695240800",
        ]
      }
    ])
  end

  context "sign with witness (dao tx)" do
    let(:tx_to_sign_hash) do
      {
        version: "0",
        cell_deps:[],
        header_deps:[],
        inputs: [
        {
          previous_output: {
            block_hash: "0x23abf65800d048ed9e3eb67e0258e0d616148e9cb1116ceee532a202b4c30e09",
                  cell: {
              tx_hash: "0x91fcfd61f420c1090aeded6b6d91d5920a279fe53ec34353afccc59264eeddd4",
                index: "0"
            }
          },
                    since: "113"
        },
        {
          previous_output: {
            block_hash: nil,
                  cell: {
              tx_hash: "0x00000000000000000000000000004e4552564f5344414f494e50555430303031",
                index: "0"
            }
          },
                    since: "0"
        }
      ],
      outputs: [
      {
        capacity: "10000009045634",
            lock: {
          code_hash: "0xf1951123466e4479842387a66fabfd6b65fc87fd84ae8e6cd3053edb27fff2fd",
               args: [
            "0x36c329ed630d6ce750712a477543672adab57f4c"
          ]
        },
            type: nil,
            data: "0x"
      }
      ],
      witnesses: [
        {
          data: [
            "0x4107bd23eedb9f2a2a749108f6bb9720d745d50f044cc4814bafe189a01fe6fb"
          ]
        },
        {
          data: []
        }
      ]
    }
    end

    let(:tx_hash) { "0x985772e541c23d4e7dbf9844a9b9d93fcdc62273fa1f4ae1ae82703962dc1a4e" }

    let(:private_key) { "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3" }
    let(:key) { CKB::Key.new(private_key) }

    it "sign" do
      tx_to_sign = CKB::Types::Transaction.from_h(tx_to_sign_hash)
      signed_tx = tx_to_sign.sign(key, tx_hash)

      expect(signed_tx.hash).to eq tx_hash
      expect(signed_tx.witnesses.map(&:to_h)).to eq([
        {
          data: [
            "0x68a57373f4e98aecfb9501ec1cc4a78c048361332e4b6706bdc1469d30bd52ea42feca657dd1de1eff384e6ed24a6910b011d49d855bd1ed209f5ce77d8116ac01",
            "0x4107bd23eedb9f2a2a749108f6bb9720d745d50f044cc4814bafe189a01fe6fb"
          ]
        },
        {
          data: [
            "0x3b13c362f254e7becb0e731e4756e742bfddbf2f5d7c16cd609ba127d2b7e07f1d588c3a7132fc20c478e2de14f6370fbb9e4402d240e4b32c8d671177e1f31101"
          ]
        }
      ])
    end

    it "should build correct hash when args is empty " do
      skip if ENV["SKIP_RPC_TESTS"]
      api = CKB::API.new
      block = api.get_block_by_number(1000)
      tx = block.transactions.first
      tx_binary = CKB::Serializers::RawTransactionSerializer.new(tx).serialize
      blake2b = CKB::Blake2b.new
      blake2b << CKB::Utils.hex_to_bin("0x#{tx_binary}")
      expected_tx_hash = blake2b.hexdigest

      expect(
        expected_tx_hash
      ).to eq tx.hash
    end
  end
end
