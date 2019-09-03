require "pry"
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
  end

  context "tx_hash" do
    it "should build correct hash for specific transaction" do
      tx_h = {
        :version=>"0",
        :cell_deps=>[],
        :header_deps=>[],
        :inputs=>
          [{:previous_output=>
              {:tx_hash=>"0x0000000000000000000000000000000000000000000000000000000000000000", :index=>"4294967295"},
            :since=>"1000"}],
        :outputs=>
          [{:capacity=>"125488283274",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x0001acc717d6424ee6efdd84e0c5befb8e44a89c"],
               :hash_type=>"type"},
            :type=>nil}],
        :outputs_data=>["0x48656c6c6f2c204b652057616e67212120456e6a6f7921"],
        :witnesses=>
          [{:data=>
              ["0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e8801", "0x0001acc717d6424ee6efdd84e0c5befb8e44a89c"]}],
        :hash=>"0xa6d3c96424b16b35897b254f8d02c58dffd7ddf73aa0fe6781b0ee7a1a3e6896"
      }
      tx = CKB::Types::Transaction.from_h(tx_h)
      tx_binary = CKB::Serializers::RawTransactionSerializer.new(tx).serialize
      blake2b = CKB::Blake2b.new
      blake2b << CKB::Utils.hex_to_bin("0x#{tx_binary}")
      expected_tx_hash = blake2b.hexdigest

      expect(
        expected_tx_hash
      ).to eq tx.hash
    end

    it "should build correct hash when tx has one cell_deps" do
      tx_h = {
        :version=>"0",
        :cell_deps=>
          [{:out_point=>{:tx_hash=>"0xc12386705b5cbb312b693874f3edf45c43a274482e27b8df0fd80c8d3f5feb8b", :index=>"0"},
            :dep_type=>"dep_group"}],
        :header_deps=>[],
        :inputs=>
          [{:previous_output=>
              {:tx_hash=>"0x1a565d7d24705b65aea74e7c5cdbbdf43f00c1a0b9f7e11e4bde0f54321bb429", :index=>"1"},
            :since=>"0"}],
        :outputs=>
          [{:capacity=>"100000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0xf485c551e77fc77750115a36b7d2033fbab00951"],
               :hash_type=>"type"},
            :type=>nil},
           {:capacity=>"98624000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x59a27ef3ba84f061517d13f42cf44ed020610061"],
               :hash_type=>"type"},
            :type=>nil}],
        :outputs_data=>["0x", "0x"],
        :witnesses=>
          [{:data=>
              ["0x7d31e525720fd16d5500aad97f92ee87a97e9510259621c77776f75f8703b90618bd07ff2d5a447553df272d1203ce090dd11f236fbd60f992a49445ff09d8fd01"]}],
        :hash=>"0xf880ae727eaf2dec563c7ea943c24f7496ccf2fb077af408347a17701eb52ee3"
      }
      tx = CKB::Types::Transaction.from_h(tx_h)
      tx_binary = CKB::Serializers::RawTransactionSerializer.new(tx).serialize
      blake2b = CKB::Blake2b.new
      blake2b << CKB::Utils.hex_to_bin("0x#{tx_binary}")
      expected_tx_hash = blake2b.hexdigest

      expect(
        expected_tx_hash
      ).to eq tx.hash
    end

    it "should build correct hash when tx has multiple cell_deps" do
      tx_h = {
        :version=>"0",
        :cell_deps=>
          [{:out_point=>{:tx_hash=>"0xc12386705b5cbb312b693874f3edf45c43a274482e27b8df0fd80c8d3f5feb8b", :index=>"0"},
            :dep_type=>"dep_group"}],
        :header_deps=>[],
        :inputs=>
          [{:previous_output=>
              {:tx_hash=>"0x1a565d7d24705b65aea74e7c5cdbbdf43f00c1a0b9f7e11e4bde0f54321bb429", :index=>"1"},
            :since=>"0"}],
        :outputs=>
          [{:capacity=>"100000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0xf485c551e77fc77750115a36b7d2033fbab00951"],
               :hash_type=>"type"},
            :type=>nil},
           {:capacity=>"98624000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x59a27ef3ba84f061517d13f42cf44ed020610061"],
               :hash_type=>"type"},
            :type=>nil}],
        :outputs_data=>["0x", "0x"],
        :witnesses=>
          [{:data=>
              ["0x7d31e525720fd16d5500aad97f92ee87a97e9510259621c77776f75f8703b90618bd07ff2d5a447553df272d1203ce090dd11f236fbd60f992a49445ff09d8fd01"]}],
        :hash=>"0xf880ae727eaf2dec563c7ea943c24f7496ccf2fb077af408347a17701eb52ee3"
      }
      tx = CKB::Types::Transaction.from_h(tx_h)
      tx_binary = CKB::Serializers::RawTransactionSerializer.new(tx).serialize
      blake2b = CKB::Blake2b.new
      blake2b << CKB::Utils.hex_to_bin("0x#{tx_binary}")
      expected_tx_hash = blake2b.hexdigest

      expect(
        expected_tx_hash
      ).to eq tx.hash
    end

    it "should build correct hash when has dep_type is code cell_dep" do
      tx_h = {
        :version=>"0",
        :cell_deps=>
          [{:out_point=>{:tx_hash=>"0x0fb4945d52baf91e0dee2a686cdd9d84cad95b566a1d7409b970ee0a0f364f60", :index=>"2"},
            :dep_type=>"code"},
           {:out_point=>{:tx_hash=>"0xc12386705b5cbb312b693874f3edf45c43a274482e27b8df0fd80c8d3f5feb8b", :index=>"0"},
            :dep_type=>"dep_group"}],
        :header_deps=>
          ["0x28a548494dfc02a952f5ae25bf2886abb7ba5a8092bd139700641b4979a57217", "0x3bff5d655b9e309f0d0bfea2b792e720a88df702a5724dbb9beef92516827b3f"],
        :inputs=>
          [{:previous_output=>
              {:tx_hash=>"0x9d1bf801b235ce62812844f01381a070c0cc72876364861e00492eac1d8b54e7", :index=>"0"},
            :since=>"67744"}],
        :outputs=>
          [{:capacity=>"100533620439",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x59a27ef3ba84f061517d13f42cf44ed020610061"],
               :hash_type=>"type"},
            :type=>nil}],
        :outputs_data=>["0x"],
        :witnesses=>
          [{:data=>
              ["0x25d094fdab0bfbb0261f4d665a340bfcfca1cc33be317b654dd1ea2a9c42b05847cfe13ce5eae67335858295e456ebc3d40bf44f98e862974799890d6401215300",
               "0x0000000000000000"]}],
        :hash=>"0xf50bfe4da5a3378262769d35fd489468a89a525bc40a73d678fdb8c603c6cfb0"
      }

      tx = CKB::Types::Transaction.from_h(tx_h)
      tx_binary = CKB::Serializers::RawTransactionSerializer.new(tx).serialize
      blake2b = CKB::Blake2b.new
      blake2b << CKB::Utils.hex_to_bin("0x#{tx_binary}")
      expected_tx_hash = blake2b.hexdigest

      expect(
        expected_tx_hash
      ).to eq tx.hash
    end

    it "should build correct hash when has type script" do
      tx_h = {
        :version=>"0",
        :cell_deps=>
          [{:out_point=>{:tx_hash=>"0xc12386705b5cbb312b693874f3edf45c43a274482e27b8df0fd80c8d3f5feb8b", :index=>"0"},
            :dep_type=>"dep_group"},
           {:out_point=>{:tx_hash=>"0x0fb4945d52baf91e0dee2a686cdd9d84cad95b566a1d7409b970ee0a0f364f60", :index=>"2"},
            :dep_type=>"code"}],
        :header_deps=>[],
        :inputs=>
          [{:previous_output=>
              {:tx_hash=>"0x31f695263423a4b05045dd25ce6692bb55d7bba2965d8be16b036e138e72cc65", :index=>"1"},
            :since=>"0"}],
        :outputs=>
          [{:capacity=>"100000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x59a27ef3ba84f061517d13f42cf44ed020610061"],
               :hash_type=>"type"},
            :type=>
              {:code_hash=>"0xece45e0979030e2f8909f76258631c42333b1e906fd9701ec3600a464a90b8f6",
               :args=>[],
               :hash_type=>"data"}},
           {:capacity=>"98824000000000",
            :lock=>
              {:code_hash=>"0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
               :args=>["0x59a27ef3ba84f061517d13f42cf44ed020610061"],
               :hash_type=>"type"},
            :type=>nil}],
        :outputs_data=>["0x", "0x"],
        :witnesses=>
          [{:data=>
              ["0x82df73581bcd08cb9aa270128d15e79996229ce8ea9e4f985b49fbf36762c5c37936caf3ea3784ee326f60b8992924fcf496f9503c907982525a3436f01ab32900"]}],
        :hash=>"0x9d1bf801b235ce62812844f01381a070c0cc72876364861e00492eac1d8b54e7"
      }

      tx = CKB::Types::Transaction.from_h(tx_h)
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
