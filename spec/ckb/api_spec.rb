RSpec.describe CKB::API do
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:api) { CKB::API.new }
  let(:lock_hash) { "0x266cec97cbede2cfbce73666f08deed9560bdf7841a7a5a51b3a3f09da249e21" }

  it "genesis block" do
    result = api.genesis_block
    expect(result).not_to be nil
  end

  it "genesis block hash" do
    result = api.genesis_block_hash
    expect(result).not_to be nil
  end

  it "get block" do
    genesis_block_hash = api.genesis_block_hash
    result = api.get_block(genesis_block_hash)
    expect(result).not_to be nil
    expect(result[:header][:hash]).to eq genesis_block_hash
  end

  it "get block by number" do
    block_number = "0"
    result = api.get_block_by_number(block_number)
    expect(result).not_to be nil
    expect(result[:header][:number]).to eq block_number
  end

  it "get tip header" do
    result = api.get_tip_header
    expect(result).not_to be nil
    expect(result[:number].to_i > 0).to be true
  end

  it "get tip block number" do
    result = api.get_tip_block_number
    expect(result.to_i > 0).to be true
  end

  it "get cells by lock hash" do
    result = api.get_cells_by_lock_hash(lock_hash, '0', '100')
    expect(result).not_to be nil
  end

  it "get transaction" do
    tx = api.genesis_block[:transactions].first
    result = api.get_transaction(tx[:hash])
    expect(result).not_to be nil
    expect(result[:transaction][:hash]).to eq tx[:hash]
  end

  it "get live cell" do
    cells = api.get_cells_by_lock_hash(lock_hash, '0', '100')
    result = api.get_live_cell(cells[0][:out_point])
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
      api.send_transaction(tx)
    }.to raise_error(CKB::RPCError, /:code=>-3/)
  end

  it "local node info" do
    result = api.local_node_info
    expect(result).not_to be nil
    expect(result[:addresses].empty?).not_to be true
    expect(result[:node_id].empty?).not_to be true
  end

  it "trace empty transaction" do
    tx = {
      version: 0,
      deps: [],
      inputs: [],
      outputs: []
    }

    # result = api.trace_transaction(tx)
    # expect(result).not_to be nil
    expect {
      api.trace_transaction(tx)
    }.to raise_error(CKB::RPCError, /:code=>-3/)
  end

  it "get empty transaction trace" do
    trace_tx_hash = "0x1704f772f11c4c2fcb543f22cad66adad5a555e21f14c975c37d1d4bad096d47"
    result = api.get_transaction_trace(trace_tx_hash)
    expect(result).to be nil
  end
end
