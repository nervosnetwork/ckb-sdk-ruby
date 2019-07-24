RSpec.describe CKB::Types::Block do
  let(:block_h) do
    {
      "transactions": [
        {
          "deps": [
            "block_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
            "cell": {
              "tx_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
              "index": "4294967295"
            }
          ],
          "hash": "0xbd9ed8dec5288bdeb2ebbcc4c118a8adb6baab07a44ea79843255ccda6c57915",
          "inputs": [
            {
              "args": [
                "0x0100000000000000"
              ],
              "previous_output": {
                "block_hash": nil,
                "cell": {
                  "tx_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                  "index": "4294967295"
                }
              },
              "since": "0"
            }
          ],
          "outputs": [
            {
              "capacity": "50000",
              "data": "0x",
              "lock": {
                "args": [],
                "code_hash": "0x0000000000000000000000000000000000000000000000000000000000000001"
              },
              "type": nil
            }
          ],
          "version": "0",
          "witnesses": [
            {
                data: "0x1234"
            }
          ]
        }
      ],
      "header": {
        "difficulty": "0x100",
        "hash": "0xef285e5da29247ce39385cbd8dc36535f7ea1b5b0379db26e9d459a8b47d0d71",
        "number": "1",
        "parent_hash": "0xf17b8bfe49aaa018610d20a19aa6a0639882a774c47bcb7623a085a59ee13d42",
        "dao": "0x0100000000000000747d1c3822f724000053285dc3820400007d3449d6740000",
        "seal": {
          "nonce": "14785007515249450415",
          "proof": "0xa00600005a0a00001c21000009230000db240000fb350000523600005f4b0000bb4b00000a4d00001b56000070700000"
        },
        "timestamp": "1555422499746",
        "transactions_root": "0xbd9ed8dec5288bdeb2ebbcc4c118a8adb6baab07a44ea79843255ccda6c57915",
        "proposals_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "uncles_count": "0",
        "uncles_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "version": "0",
        "witnesses_root": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      "proposals": [],
      "uncles": []
    }
  end

  it "from_h" do
    expect {
      CKB::Types::Block.from_h(block_h)
    }.not_to raise_error
  end

  it "to_h" do
    expect {
      block = CKB::Types::Block.from_h(block_h)
      block.to_h
    }.not_to raise_error
  end
end
