RSpec.describe CKB::Types::TransactionTemplate do
  let(:transaction_template_h) do
    {
      :hash=>"0x6d6e478ae632208f4cc4120078bba78852e88ef136e8c5cc8c102b1e21c62dad",
      :required=>false,
      :cycles=>"0x7a1200",
      :depends=> %w(0x3a1200 0x2a1200),
      :data=> {
        :version=>"0x0",
        :cell_deps=>[],
        :header_deps=>[],
        :inputs=>[
          {
            :args=>[],
            :previous_output=>{
              :tx_hash=>"0xa80a8e01d45b10e1cbc8a2557c62ba40edbdc36cd63a31fc717006ca7b157b50",
              :index=>"0x0"
            },
            :since=>"0x0"
          }
        ],
        :outputs=>[
          {
            :capacity=>"0x174876e800",
            :lock=>{
              :code_hash=>"0x9e3b3557f11b2b3532ce352bfe8017e9fd11d154c4c7f9b7aaaa1e621b539a08",
              :args=>[
                "0xe2193df51d78411601796b35b17b4f8f2cd85bd0"
              ],
              :hash_type=>"type"
            },
            :type=>nil
          }
        ],
        :outputs_data=>["0x"],
        :witnesses=>[
          {
            :data=> %w(0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df201 0x3954acece65096bfa81258983ddb83915fc56bd8)
          }
        ]
      }
    }
  end

  let(:transaction_template) { CKB::Types::TransactionTemplate.from_h(transaction_template_h) }

  it "from_h" do
    expect(CKB::Types::TransactionTemplate.from_h(transaction_template_h)).to be_a(CKB::Types::TransactionTemplate)
  end

  it "to_h" do
    data = transaction_template.to_h[:data]
    expect(
      transaction_template.to_h.reject { |key| key == :data }
    ).to eq transaction_template_h.reject { |key| key == :data }

    expect(CKB::Types::Transaction.from_h(data)).to be_a(CKB::Types::Transaction)
  end
end
