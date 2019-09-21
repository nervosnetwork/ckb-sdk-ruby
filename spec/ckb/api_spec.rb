RSpec.describe CKB::API do
  Types = CKB::Types

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:api) { CKB::API.new }
  let(:lock_hash) { "0xe94e4b509d5946c54ea9bc7500af12fd35eebe0d47a6b3e502127f94d34997ac" }

  it "genesis block" do
    expect(api.genesis_block).to be_a(Types::Block)
  end

  it "genesis block hash" do
    expect(api.genesis_block_hash).to be_a(String)
  end

  it "get block" do
    genesis_block_hash = api.get_block_hash(0)
    result = api.get_block(genesis_block_hash)
    expect(result).to be_a(Types::Block)
  end

  it "get block by number" do
    block_number = 0
    result = api.get_block_by_number(block_number)
    expect(result).to be_a(Types::Block)
    expect(result.header.number).to eq block_number
  end

  it "get tip header" do
    result = api.get_tip_header
    expect(result).to be_a(Types::BlockHeader)
    expect(result.number > 0).to be true
  end

  it "get tip block number" do
    result = api.get_tip_block_number
    expect(result > 0).to be true
  end

  it "get cells by lock hash" do
    result = api.get_cells_by_lock_hash(lock_hash, 0, 100)
    expect(result).not_to be nil
  end

  it "get transaction" do
    tx = api.genesis_block.transactions.first
    result = api.get_transaction(tx.hash)
    expect(result).to be_a(Types::TransactionWithStatus)
    expect(result.transaction.hash).to eq tx.hash
  end

  it "get live cell with data" do
    out_point = Types::OutPoint.new(tx_hash: "0x45d086fe064ada93b6c1a6afbfd5e441d08618d326bae7b7bbae328996dfd36a", index: 0)
    result = api.get_live_cell(out_point, true)
    expect(result).not_to be nil
  end

  it "get live cell without data" do
    out_point = Types::OutPoint.new(tx_hash: "0x45d086fe064ada93b6c1a6afbfd5e441d08618d326bae7b7bbae328996dfd36a", index: 0)
    result = api.get_live_cell(out_point)
    expect(result).not_to be nil
  end

  it "send empty transaction" do
    tx = Types::Transaction.new(
      version: 0,
      cell_deps: [],
      inputs: [],
      outputs: []
    )

    expect {
      api.send_transaction(tx)
    }.to raise_error(CKB::RPCError, /:code=>-3/)
  end

  it "get current epoch" do
    result = api.get_current_epoch
    expect(result).not_to be nil
    expect(result).to be_a(Types::Epoch)
  end

  it "get epoch by number" do
    number = 0
    result = api.get_epoch_by_number(number)
    expect(result).to be_a(Types::Epoch)
    expect(result.number).to eq number
  end

  it "local node info" do
    result = api.local_node_info
    expect(result).to be_a(Types::Peer)
  end

  it "get peers" do
    result = api.get_peers
    expect(result).not_to be nil
  end

  it "tx pool info" do
    result = api.tx_pool_info
    expect(result).to be_a(Types::TxPoolInfo)
    expect(result.pending >= 0).to be true
  end

  it "get blockchain info" do
    result = api.get_blockchain_info
    expect(result).to be_a(Types::ChainInfo)
    expect(result.epoch >= 0).to be true
  end

  it "get peers state" do
    result = api.get_peers_state
    expect(result).to be_an(Array)
  end

  it "dry run transaction" do
    tx = Types::Transaction.new(
      version: 0,
      cell_deps: [],
      inputs: [],
      outputs: []
    )

    result = api.dry_run_transaction(tx)
    expect(result).to be_a(Types::DryRunResult)
    expect(result.cycles >= 0).to be true
  end

  context "indexer RPCs" do
    it "index_lock_hash" do
      result = api.index_lock_hash(lock_hash)
      expect(result).not_to be nil
    end

    it "deindex_lock_hash" do
      result = api.deindex_lock_hash(lock_hash)
      expect(result).to be nil
    end

    it "get_lock_hash_index_states" do
      result = api.get_lock_hash_index_states
      expect(result).not_to be nil
    end

    it "get_live_cells_by_lock_hash" do
      result = api.get_live_cells_by_lock_hash(lock_hash, 0, 10)
      expect(result).not_to be nil
    end

    it "get_transactions_by_lock_hash" do
      result = api.get_transactions_by_lock_hash(lock_hash, 0, 10)
      expect(result).not_to be nil
    end
  end

  it "get block header" do
    block_hash = api.get_block_hash(1)
    result = api.get_header(block_hash)
    expect(result).to be_a(Types::BlockHeader)
    expect(result.number > 0).to be true
  end

  it "get block header by number" do
    block_number = 1
    result = api.get_header_by_number(block_number)
    expect(result).to be_a(Types::BlockHeader)
    expect(result.number).to eq block_number
  end

  it "get block reward by block hash" do
    block_hash = api.get_block_hash(1)
    result = api.get_cellbase_output_capacity_details(block_hash)
    expect(result).to be_a(Types::BlockReward)
  end

  it "set ban" do
    params = ["192.168.0.2", "insert", 1840546800000, true, "test set_ban rpc"]
    result = api.set_ban(*params)
    expect(result).to be nil
  end

  it "get banned addresses" do
    result = api.get_banned_addresses
    expect(result).not_to be nil
    expect(result).to all(be_a(Types::BannedAddress))
  end
end
