RSpec.describe CKB::RPC do
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:rpc) { CKB::RPC.new }
  let(:lock_hash) { "0xe94e4b509d5946c54ea9bc7500af12fd35eebe0d47a6b3e502127f94d34997ac" }

  it "genesis block" do
    result = rpc.genesis_block
    expect(result).not_to be nil
    expect(result[:header][:number]).to eq "0"
  end

  it "genesis block hash" do
    result = rpc.genesis_block_hash
    expect(result).not_to be nil
  end

  it "get block" do
    genesis_block_hash = rpc.get_block_hash("0")
    result = rpc.get_block(genesis_block_hash)
    expect(result).not_to be nil
    expect(result[:header][:hash]).to eq genesis_block_hash
  end

  it "get block by number" do
    block_number = "0"
    result = rpc.get_block_by_number(block_number)
    expect(result).not_to be nil
    expect(result[:header][:number]).to eq block_number
  end

  it "get tip header" do
    result = rpc.get_tip_header
    expect(result).not_to be nil
    expect(result[:number].to_i > 0).to be true
  end

  it "get tip block number" do
    result = rpc.get_tip_block_number
    expect(result.to_i > 0).to be true
  end

  it "get cells by lock hash" do
    result = rpc.get_cells_by_lock_hash(lock_hash, '0', '100')
    expect(result).not_to be nil
  end

  it "get transaction" do
    tx = rpc.genesis_block[:transactions].first
    result = rpc.get_transaction(tx[:hash])
    expect(result).not_to be nil
    expect(result[:transaction][:hash]).to eq tx[:hash]
  end

  it "get live cell" do
    out_point = {
      block_hash: nil,
      cell: {
        tx_hash: "0x45d086fe064ada93b6c1a6afbfd5e441d08618d326bae7b7bbae328996dfd36a",
        index: "0"
      }
    }
    result = rpc.get_live_cell(out_point)
    expect(result).not_to be nil
  end

  it "send empty transaction" do
    tx = {
      version: 0,
      deps: [],
      inputs: [],
      outputs: []
    }

    expect {
      rpc.send_transaction(tx)
    }.to raise_error(CKB::RPCError, /:code=>-3/)
  end

  it "local node info" do
    result = rpc.local_node_info
    expect(result).not_to be nil
    expect(result[:addresses].empty?).not_to be true
    expect(result[:node_id].empty?).not_to be true
  end

  it "get epoch by number" do
    number = '0'
    result = rpc.get_epoch_by_number(number)
    expect(result).to be_a(Hash)
    expect(result[:number]).to eq number
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
    block_hash = rpc.get_block_hash("1")
    result = rpc.get_header(block_hash)
    expect(result[:number].to_i > 0).to be true
  end

  it "get block header by number" do
    block_number = "1"
    result = rpc.get_header_by_number(block_number)
    expect(result[:number]).to eq block_number
  end

  it "get block reward by block hash" do
    block_hash = rpc.get_block_hash("1")
    result = rpc.get_cellbase_output_capacity_details(block_hash)
    expect(result).not_to be nil
  end

  it "set ban" do
    params = ["192.168.0.2", "insert", "1840546800000", true, "test set_ban rpc"]
    result = rpc.set_ban(*params)
    expect(result).to be nil
  end

  it "get banned addresses" do
    result = rpc.get_banned_addresses
    expect(result).not_to be nil
  end
end
