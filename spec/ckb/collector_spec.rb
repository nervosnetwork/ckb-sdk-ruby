RSpec.describe CKB::Collector do
  it "should return an empty array when there are no live cells under the search_key" do
    payer_lock = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb", hash_type: "type")
    search_key = CKB::Indexer::Types::SearchKey.new(payer_lock, "lock")
    stub = instance_double("CKB::Indexer::API")
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      CKB::Indexer::Types::LiveCells.new(last_cursor: nil, objects: [])
    end

    expect(CKB::Collector.new(stub).default_indexer(search_keys: [search_key])).to match_array([])
  end

  it "should return one live cell when there are only one live cell under the search_key" do
    payer_lock = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb", hash_type: "type")
    search_key = CKB::Indexer::Types::SearchKey.new(payer_lock, "lock")
    stub = instance_double("CKB::Indexer::API")
    out_point = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell = CKB::Indexer::Types::LiveCell.new(block_number: 12345, out_point: out_point, output: output, output_data: "0x", tx_index: 0)
    live_cells = CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [live_cell])
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      live_cells
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: "0x") do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end
    expected_rs = live_cells.objects.map do |cell|
      CKB::CellMeta.new(api: nil, out_point: cell.out_point, output: cell.output, output_data_len: CKB::Utils.hex_to_bin(cell.output_data).bytesize, cellbase: nil)
    end

    expect(CKB::Collector.new(stub).default_indexer(search_keys: [search_key])).to match_array(expected_rs)
  end

  it "should return three live cells when there are three live cells under the search_key" do
    payer_lock = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb", hash_type: "type")
    search_key = CKB::Indexer::Types::SearchKey.new(payer_lock, "lock")
    stub = instance_double("CKB::Indexer::API")
    out_point = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell = CKB::Indexer::Types::LiveCell.new(block_number: 12345, out_point: out_point, output: output, output_data: "0x", tx_index: 0)
    out_point1 = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output1 = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell1 = CKB::Indexer::Types::LiveCell.new(block_number: 12346, out_point: out_point1, output: output1, output_data: "0x", tx_index: 0)
    out_point2 = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output2 = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell2 = CKB::Indexer::Types::LiveCell.new(block_number: 12347, out_point: out_point2, output: output2, output_data: "0x", tx_index: 0)
    live_cells = CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [live_cell, live_cell1, live_cell2])
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      live_cells
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: "0x") do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end
    expected_rs = live_cells.objects.map do |cell|
      CKB::CellMeta.new(api: nil, out_point: cell.out_point, output: cell.output, output_data_len: CKB::Utils.hex_to_bin(cell.output_data).bytesize, cellbase: nil)
    end

    expect(CKB::Collector.new(stub).default_indexer(search_keys: [search_key])).to match_array(expected_rs)
  end

  it "should return one live cell for the search key A and return an empty array for search key B when B does not have any live cells" do
    payer_lock = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb", hash_type: "type")
    search_key = CKB::Indexer::Types::SearchKey.new(payer_lock, "lock")
    stub = instance_double("CKB::Indexer::API")
    out_point = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell = CKB::Indexer::Types::LiveCell.new(block_number: 12345, out_point: out_point, output: output, output_data: "0x", tx_index: 0)
    live_cells = CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [live_cell])
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      live_cells
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: "0x") do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end
    expected_rs = live_cells.objects.map do |cell|
      CKB::CellMeta.new(api: nil, out_point: cell.out_point, output: cell.output, output_data_len: CKB::Utils.hex_to_bin(cell.output_data).bytesize, cellbase: nil)
    end
    payer_lock1 = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0x#{SecureRandom.hex(20)}", hash_type: "type")
    search_key1 = CKB::Indexer::Types::SearchKey.new(payer_lock1, "lock")
    allow(stub).to receive(:get_cells).with(search_key: search_key1, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end

    expect(CKB::Collector.new(stub).default_indexer(search_keys: [search_key])).to match_array(expected_rs)
  end

  it "should return one live cell for the search key A and return two live cells for search key B" do
    payer_lock = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0xedcda9513fa030ce4308e29245a22c022d0443bb", hash_type: "type")
    search_key = CKB::Indexer::Types::SearchKey.new(payer_lock, "lock")
    stub = instance_double("CKB::Indexer::API")
    out_point = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell = CKB::Indexer::Types::LiveCell.new(block_number: 12345, out_point: out_point, output: output, output_data: "0x", tx_index: 0)
    live_cells = CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [live_cell])
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      live_cells
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: "0x") do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end
    payer_lock1 = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", args: "0x#{SecureRandom.hex(20)}", hash_type: "type")
    search_key1 = CKB::Indexer::Types::SearchKey.new(payer_lock1, "lock")
    out_point1 = CKB::Types::OutPoint.new(tx_hash: "0x#{SecureRandom.hex(32)}", index: 0)
    output1 = CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(100), lock: payer_lock)
    live_cell1 = CKB::Indexer::Types::LiveCell.new(block_number: 12346, out_point: out_point1, output: output1, output_data: "0x", tx_index: 0)
    live_cells1 = CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [live_cell1])
    expected_rs = live_cells.objects.map do |cell|
      CKB::CellMeta.new(api: nil, out_point: cell.out_point, output: cell.output, output_data_len: CKB::Utils.hex_to_bin(cell.output_data).bytesize, cellbase: nil)
    end + live_cells1.objects.map do |cell|
      CKB::CellMeta.new(api: nil, out_point: cell.out_point, output: cell.output, output_data_len: CKB::Utils.hex_to_bin(cell.output_data).bytesize, cellbase: nil)
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key1, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: nil) do
      live_cells1
    end
    allow(stub).to receive(:get_cells).with(search_key: search_key1, order: "asc", limit: CKB::MAX_PAGINATES_PER, after_cursor: "0x") do
      CKB::Indexer::Types::LiveCells.new(last_cursor: "0x", objects: [])
    end
    expect(CKB::Collector.new(stub).default_indexer(search_keys: [search_key, search_key1])).to match_array(expected_rs)
  end
end
