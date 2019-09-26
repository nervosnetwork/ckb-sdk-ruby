# frozen_string_literal: true

RSpec.describe CKB::API do
  Types = CKB::Types

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:api) { CKB::API.new }
  let(:lock_hash) { "0xe94e4b509d5946c54ea9bc7500af12fd35eebe0d47a6b3e502127f94d34997ac" }
  let(:block_h) do
    { uncles: [],
      proposals: [],
      transactions: [{ hash: "0x8ad0468383d0085e26d9c3b9b648623e4194efc53a03b7cd1a79e92700687f1e",
                       version: "0x0",
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
                                              0x3954acece65096bfa81258983ddb83915fc56bd8] }] }],
      header: { difficulty: "0x100",
                hash: "0xd629a10a08fb0f43fcb97e948fc2b6eb70ebd28536490fe3864b0e40d08397d1",
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

    expect do
      api.send_transaction(tx)
    end.to raise_error(CKB::RPCError, /:code=>-3/)
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
    params = ["192.168.0.2", "insert", 1_840_546_800_000, true, "test set_ban rpc"]
    result = api.set_ban(*params)
    expect(result).to be nil
  end

  it "get banned addresses" do
    result = api.get_banned_addresses
    expect(result).not_to be nil
    expect(result).to all(be_a(Types::BannedAddress))
  end

  context "miner APIs" do
    it "get_block_template" do
      result = api.get_block_template
      expect(result).not_to be nil
    end

    it "get_block_template with bytes_limit" do
      result = api.get_block_template(bytes_limit: 1000)
      expect(result).to be_a(Types::BlockTemplate)
    end

    it "get_block_template with proposals_limit" do
      result = api.get_block_template(proposals_limit: 1000)
      expect(result).to be_a(Types::BlockTemplate)
    end

    it "get_block_template with max_version" do
      result = api.get_block_template(max_version: 1000)
      expect(result).to be_a(Types::BlockTemplate)
    end

    it "get_block_template with bytes_limit, proposals_limit and max_version" do
      result = api.get_block_template(max_version: 1000)
      expect(result).to be_a(Types::BlockTemplate)
    end

    it "submit_block should return block hash" do
      block = Types::Block.from_h(block_h)
      result = api.submit_block(work_id: "test", raw_block_h: block.to_raw_block_h)
      expect(result).to be_a(String)
    end
  end
end
