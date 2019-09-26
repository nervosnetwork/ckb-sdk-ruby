# frozen_string_literal: true
RSpec.describe CKB::RPC do
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end
  let(:raw_block_h) do
    { uncles: [],
      proposals: [],
      transactions: [{ version: "0x0",
                       cell_deps: [],
                       header_deps: [],
                       inputs: [{ previous_output: { tx_hash: "0x0000000000000000000000000000000000000000000000000000000000000000", index: "0xffffffff" },
                                  since: "0x1" }],
                       outputs: [{ capacity: "0x2ca7071b9e",
                                   lock: { code_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
                                           args: [],
                                           hash_type: "type" },
                                   type: nil }],
                       outputs_data: ["0x"],
                       witnesses: [{ data: %w[0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df201
                                              0x3954acece65096bfa81258983ddb83915fc56bd8] }]}],
      header: { difficulty: "0x100",
                number: "0x1",
                parent_hash: "0x6944997e76680c03a7b30fa8b1d30da9e77685de5b28796898b05c6e6e3f9ace",
                nonce: "0xd20cf913474dbf0e",
                timestamp: "0x16d6731e6e1",
                transactions_root: "0x761909b19c96df2b38283bcd6ddf7162a1947e3fad2be70c32f3c7596ddcfad3",
                proposals_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
                uncles_count: "0x0",
                uncles_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
                version: "0x0",
                witnesses_root: "0x4c1f2995e6507bd45f0295dd775b9d6c9cd21fc775f95582fe2a6ce0ed8ee00a",
                epoch: "0x3e80001000000",
                dao: "0x2c7ecb6d26870700f1d8f5e035872300683cb95e9a0000000094b5c67d7a0100" } }
  end
  let(:rpc) { CKB::RPC.new }
  let(:lock_hash) { "0xd0e22f863da970a3ff51a937ae78ba490bbdcede7272d658a053b9f80e30305d" }

  it "genesis block" do
    result = rpc.genesis_block
    expect(result).not_to be nil
    expect(result[:header][:number]).to eq "0x0"
  end

  it "genesis block hash" do
    result = rpc.genesis_block_hash
    expect(result).not_to be nil
  end

  it "get block" do
    genesis_block_hash = rpc.get_block_hash(0)
    result = rpc.get_block(genesis_block_hash)
    expect(result).not_to be nil
    expect(result[:header][:hash]).to eq genesis_block_hash
  end

  it "get block by number" do
    result = rpc.get_block_by_number(0)
    expect(result).not_to be nil
    expect(result[:header][:number]).to eq "0x0"
  end

  it "get tip header" do
    result = rpc.get_tip_header
    expect(result).not_to be nil
    expect(result[:number].hex > 0).to be true
  end

  it "get tip block number" do
    result = rpc.get_tip_block_number
    expect(result.hex > 0).to be true
  end

  it "get cells by lock hash" do
    result = rpc.get_cells_by_lock_hash(lock_hash, 0, 100)
    expect(result).not_to be nil
  end

  it "get transaction" do
    tx = rpc.genesis_block[:transactions].first
    result = rpc.get_transaction(tx[:hash])
    expect(result).not_to be nil
    expect(result[:transaction][:hash]).to eq tx[:hash]
  end

  it "get live cell with data" do
    out_point = {
      tx_hash: "0x45d086fe064ada93b6c1a6afbfd5e441d08618d326bae7b7bbae328996dfd36a",
      index: "0x0"
    }
    result = rpc.get_live_cell(out_point, true)
    expect(result).not_to be nil
  end

  it "get live cell without data" do
    out_point = {
      tx_hash: "0x45d086fe064ada93b6c1a6afbfd5e441d08618d326bae7b7bbae328996dfd36a",
      index: "0x0"
    }
    result = rpc.get_live_cell(out_point)
    expect(result).not_to be nil
  end

  it "send empty transaction" do
    tx = {
      version: 0,
      cell_deps: [],
      inputs: [],
      outputs: []
    }

    expect do
      rpc.send_transaction(tx)
    end.to raise_error(CKB::RPCError, /:code=>-3/)
  end

  it "local node info" do
    result = rpc.local_node_info
    expect(result).not_to be nil
    expect(result[:addresses].empty?).not_to be true
    expect(result[:node_id].empty?).not_to be true
  end

  it "get epoch by number" do
    number = 0
    result = rpc.get_epoch_by_number(number)
    expect(result).to be_a(Hash)
    expect(result[:number].hex).to eq number
  end

  context "indexer RPCs" do
    it "index_lock_hash" do
      result = rpc.index_lock_hash(lock_hash)
      expect(result).not_to be nil
    end

    it "deindex_lock_hash" do
      result = rpc.deindex_lock_hash(lock_hash)
      expect(result).to be nil
    end

    it "get_lock_hash_index_states" do
      result = rpc.get_lock_hash_index_states
      expect(result).not_to be nil
    end

    it "get_live_cells_by_lock_hash" do
      result = rpc.get_live_cells_by_lock_hash(lock_hash, 0, 10)
      expect(result).not_to be nil
    end

    it "get_transactions_by_lock_hash" do
      result = rpc.get_transactions_by_lock_hash(lock_hash, 0, 10)
      expect(result).not_to be nil
    end
  end

  it "get block header" do
    block_hash = rpc.get_block_hash(1)
    result = rpc.get_header(block_hash)
    expect(result[:number].hex > 0).to be true
  end

  it "get block header by number" do
    block_number = 1
    result = rpc.get_header_by_number(block_number)
    expect(result[:number].hex).to eq block_number
  end

  it "get block reward by block hash" do
    block_hash = rpc.get_block_hash(1)
    result = rpc.get_cellbase_output_capacity_details(block_hash)
    expect(result).not_to be nil
  end

  it "set ban" do
    params = ["192.168.0.2", "insert", 1_840_546_800_000, true, "test set_ban rpc"]
    result = rpc.set_ban(*params)
    expect(result).to be nil
  end

  it "get banned addresses" do
    result = rpc.get_banned_addresses
    expect(result).not_to be nil
  end

  context "miner RPCs" do
    it "get_block_template" do
      result = rpc.get_block_template
      expect(result).not_to be nil
    end

    it "get_block_template with bytes_limit" do
      result = rpc.get_block_template(1000)
      expect(result).not_to be nil
    end

    it "get_block_template with proposals_limit" do
      result = rpc.get_block_template(1000)
      expect(result).not_to be nil
    end

    it "get_block_template with max_version" do
      result = rpc.get_block_template(1000)
      expect(result).not_to be nil
    end

    it "get_block_template with bytes_limit, proposals_limit and max_version" do
      result = rpc.get_block_template(1000)
      expect(result).not_to be nil
    end

    # must use real data
    it "submit_block" do
      result = rpc.submit_block("test", raw_block_h)
      expect(result).not_to be nil
    end
  end
end
