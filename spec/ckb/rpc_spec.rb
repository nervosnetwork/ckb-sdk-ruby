RSpec.describe CKB::RPC do
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:rpc) { CKB::RPC.new }
  let(:lock_hash) { "0x07bab3ada3cc0ff223b387d7f5038ef57b335aa1d8dadc418d5d8ad3b19aeadb" }

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
    cells = rpc.get_cells_by_lock_hash(lock_hash, '0', '100')
    result = rpc.get_live_cell(cells[0][:out_point])
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
end
