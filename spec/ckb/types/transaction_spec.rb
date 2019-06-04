RSpec.describe CKB::Types::Transaction do
  let(:tx_to_sign_hash) do
    {
      "version": "0",
      "deps": [
        {
          "block_hash": nil,
          "cell": {
            "tx_hash": "0xbffab7ee0a050e2cb882de066d3dbf3afdd8932d6a26eda44f06e4b23f0f4b5a",
            "index": "1"
          }
        }
      ],
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
          "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01",
          "0x304402202c643579e47045be050d3842ed9270151af8885e33954bddad0e53e81d1c2dbe02202dc637877a8302110846ebc6a16d9148c106e25f945063ad1c4d4db2b6952408"
        ]
      }
    ])
  end
end
