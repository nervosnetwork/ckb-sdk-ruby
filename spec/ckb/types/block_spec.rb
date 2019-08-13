RSpec.describe CKB::Types::Block do
  let(:block_h) do
    {
      "transactions": [
        {
          "cell_deps":[],
          "hash":"0xde27dcbd81dd174ede0749df02a883d78215b2f20d7ec8ff395ed220872b764c",
          "header_deps":[],
          "inputs":[{
            "previous_output":{
              "index":"4294967295",
              "tx_hash":"0x0000000000000000000000000000000000000000000000000000000000000000"
            },
          "since":"15"
          }],
          "outputs":[{
            "capacity":"131540290464",
            "data_hash":"0x0000000000000000000000000000000000000000000000000000000000000000",
            "lock":{
              "args":["0x3954acece65096bfa81258983ddb83915fc56bd8"],
              "code_hash":"0xa76801d09a0eabbfa545f1577084b6f3bafb0b6250e7f5c89efcfd4e3499fb55",
              "hash_type":"Data"
            },
            "type":nil
          }],
          "outputs_data":["0x"],
          "version":"0",
          "witnesses":[{
            "data":[
              "0xa76801d09a0eabbfa545f1577084b6f3bafb0b6250e7f5c89efcfd4e3499fb5500",
              "0x3954acece65096bfa81258983ddb83915fc56bd8"
            ]
          }]
       }],
      "header":{
        "dao":"0x010000000000000055309658678823000086285987fe0300008f6b7c5f6f0000",
        "difficulty":"0x100",
        "epoch":"0",
        "hash":"0x7ba460895460baa5b2a698bc3d400d33afbb64a0312ed57b1496304c011ade7a",
        "number":"15",
        "parent_hash":"0xe1a4178bc36e6abb4d3a5f00b9bac8b6e8e1e2f9b46b160e1d55b480e6247a1a",
        "proposals_hash":"0x0000000000000000000000000000000000000000000000000000000000000000",
        "seal":{
          "nonce":"2058764368806501667",
          "proof":"0x"
        },
        "timestamp":"1565665851354",
        "transactions_root":"0xde27dcbd81dd174ede0749df02a883d78215b2f20d7ec8ff395ed220872b764c",
        "uncles_count":"0",
        "uncles_hash":"0x0000000000000000000000000000000000000000000000000000000000000000",
        "version":"0",
        "witnesses_root":"0x3b84ab9739349ec9ba1bfb7da2662d3cb2f1a1e3ecc0470542fbf4b0bee25f67"
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
