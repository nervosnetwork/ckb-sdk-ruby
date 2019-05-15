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
      "witnesses": []
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
          "0x304402207c82346909c13b86a97c38a50b4868b52735ca2e7e59b14f99102159c12ff25f0220511ef5974060510e8cb363877843bd85550805f668676771bfc47e36bc5b8aa2",
          "0x4600000000000000"
        ]
      }
    ])
  end
end
