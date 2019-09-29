RSpec.describe CKB::Types::Block do
  let(:block_h) do
    {
      "header": {
        "dao": "0x0100000000000000005827f2ba13b000d77fa3d595aa00000061eb7ada030000",
        "difficulty": "0x7a1200",
        "epoch": "0x1",
        "hash": "0xd629a10a08fb0f43fcb97e948fc2b6eb70ebd28536490fe3864b0e40d08397d1",
        "nonce": "0x0",
        "number": "0x400",
        "parent_hash": "0x30a78d902d7c89ae41feaeb4652c79439e2224a3a32bc0f12059f71d86239d03",
        "proposals_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "timestamp": "0x5cd2b117",
        "transactions_root": "0x8ad0468383d0085e26d9c3b9b648623e4194efc53a03b7cd1a79e92700687f1e",
        "uncles_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "version": "0x0",
    },
    "proposals": [],
    "transactions": [
        {
            "cell_deps": [],
            "hash": "0x8ad0468383d0085e26d9c3b9b648623e4194efc53a03b7cd1a79e92700687f1e",
            "header_deps": [],
            "inputs": [
                {
                    "previous_output": {
                        "index": "0xffffffff",
                        "tx_hash": "0x0000000000000000000000000000000000000000000000000000000000000000"
                    },
                    "since": "0x400"
                }
            ],
            "outputs": [
                {
                    "capacity": "0x1057d731c2",
                    "lock": {
                        "args": [],
                        "code_hash": "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a5",
                        "hash_type": "data"
                    },
                    "type": nil
                }
            ],
            "outputs_data": [
                "0x"
            ],
            "version": "0x0",
            "witnesses": [
                {
                    "data": [
                        "0x28e83a1277d48add8e72fadaa9248559e1b632bab2bd60b27955ebc4c03800a500"
                    ]
                }
            ]
        }
      ],
      "uncles": []
    }
  end

  let(:block) { CKB::Types::Block.from_h(block_h) }

  it "from_h" do
    expect(block).to be_a(CKB::Types::Block)
    expect(block.header).to be_a(CKB::Types::BlockHeader)
    expect(block.transactions).to all(be_a(CKB::Types::Transaction))
  end

  it "to_h" do
    expect(
      block.to_h
    ).to eq block_h
  end
end
