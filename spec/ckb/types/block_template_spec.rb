RSpec.describe CKB::Types::BlockTemplate do
  let(:block_template_h) do
    {:version=>"0x0",
     :difficulty=>"0x48",
     :current_time=>"0x16d6b6111b3",
     :number=>"0xab3",
     :epoch=>"0x70806cb000001",
     :parent_hash=>"0x17784aea72da790a1a058221869c7948c7ed46f6dc2e514febcd9241baf8daa9",
     :cycles_limit=>"0x2540be400",
     :bytes_limit=>"0x25e",
     :uncles_count_limit=>"0x2",
     :uncles=>[],
     :transactions=>[],
     :proposals=>[],
     :cellbase=>
       {:cycles=>nil,
        :data=>
          {:cell_deps=>[],
           :header_deps=>[],
           :inputs=>
             [{:previous_output=>
                 {:index=>"0xffffffff", :tx_hash=>"0x0000000000000000000000000000000000000000000000000000000000000000"},
               :since=>"0xab3"}],
           :outputs=>
             [{:capacity=>"0x1a1eef7320",
               :lock=>
                 {:args=>["0x3954acece65096bfa81258983ddb83915fc56bd8"],
                  :code_hash=>"0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2",
                  :hash_type=>"type"},
               :type=>nil}],
           :outputs_data=>["0x"],
           :version=>"0x0",
           :witnesses=>
             [{:data=>
                 ["0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df201",
                  "0x3954acece65096bfa81258983ddb83915fc56bd8"]}]},
        :hash=>"0x6d6e478ae632208f4cc4120078bba78852e88ef136e8c5cc8c102b1e21c62dad"},
     :work_id=>4,
     :dao=>"0xbcbcf54f7e4b090038b2d9a13464250018f37dd3985a000000f678cfa9890100"}
  end

  let(:block_template) { CKB::Types::BlockTemplate.from_h(block_template_h) }

  it "from_h" do
    expect(CKB::Types::BlockTemplate.from_h(block_template_h)).to be_a(CKB::Types::BlockTemplate)
  end

  it "block_template's attributes value should equal with block_template_h" do
    number_keys = %i(version difficulty current_time number epoch parent_hash cycles_limit bytes_limit uncles_count_limit uncles transactions proposals cellbase work_id dao)
    number_keys.each do |key|
      expect(block_template.to_h[key]).to eq block_template_h[key]
    end
  end

  it "to_h" do
    expect(
      block_template.to_h
    ).to eq block_template_h
  end

  it "block header should contains correct attributes" do
    skip "not test api" if ENV["SKIP_RPC_TESTS"]

    api = CKB::API.new
    block_template = api.get_block_template
    expected_attributes = %w(version difficulty current_time number epoch parent_hash cycles_limit bytes_limit uncles_count_limit uncles transactions proposals cellbase work_id dao).sort

    expect(expected_attributes).to eq(block_template.instance_variables.map { |attribute| attribute.to_s.gsub("@", "") }.sort)
  end
end
