RSpec.describe CKB::API do
  Types = CKB::Types

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:api) { CKB::API.new }
  let(:lock_hash) { "0x266cec97cbede2cfbce73666f08deed9560bdf7841a7a5a51b3a3f09da249e21" }

  it "genesis block" do
    expect(api.genesis_block).to be_a(Types::Block)
  end

  it "genesis block hash" do
    expect(api.genesis_block_hash).to be_a(String)
  end

  it "get block" do
    genesis_block_hash = api.get_block_hash("0")
    result = api.get_block(genesis_block_hash)
    expect(result).to be_a(Types::Block)
  end

  it "get block by number" do
    block_number = "0"
    result = api.get_block_by_number(block_number)
    expect(result).to be_a(Types::Block)
    expect(result.header.number).to eq block_number
  end

  it "get tip header" do
    result = api.get_tip_header
    expect(result).to be_a(Types::BlockHeader)
    expect(result.number.to_i > 0).to be true
  end

  it "get tip block number" do
    result = api.get_tip_block_number
    expect(result.to_i > 0).to be true
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

  it "get live cell" do
    cells = api.get_cells_by_lock_hash(lock_hash, 0, 100)
    result = api.get_live_cell(cells[0].out_point)
    expect(result).not_to be nil
  end

  it "send empty transaction" do
    tx = Types::Transaction.new(
      version: 0,
      deps: [],
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
    expect(result.number).to eq number.to_s
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
    expect(result.epoch.to_i >= 0).to be true
  end

  it "get peers state" do
    result = api.get_peers_state
    expect(result).to be_an(Array)
  end

  it "dry run transaction" do
    tx = Types::Transaction.new(
      version: 0,
      deps: [],
      inputs: [],
      outputs: []
    )

    result = api.dry_run_transaction(tx)
    expect(result).to be_a(Types::DryRunResult)
    expect(result.cycles.to_i >= 0).to be true
  end
end
