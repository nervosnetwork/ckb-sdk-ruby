RSpec.describe CKB::Types::UncleTemplate do
  let(:uncle_template_h) do
    {
      :hash=>"0x6d6e478ae632208f4cc4120078bba78852e88ef136e8c5cc8c102b1e21c62dad",
      :required=>false,
      :proposals=>[],
      :header => {
        :dao=>"0x0100000000000000005827f2ba13b000d77fa3d595aa00000061eb7ada030000",
        :difficulty=>"0x7a1200",
        :epoch=>"0x1",
        :hash=>"0xd629a10a08fb0f43fcb97e948fc2b6eb70ebd28536490fe3864b0e40d08397d1",
        :nonce=>"0x0",
        :number=>"0x400",
        :parent_hash=>"0x30a78d902d7c89ae41feaeb4652c79439e2224a3a32bc0f12059f71d86239d03",
        :proposals_hash=>"0x0000000000000000000000000000000000000000000000000000000000000000",
        :timestamp=>"0x5cd2b117",
        :transactions_root=>"0x8ad0468383d0085e26d9c3b9b648623e4194efc53a03b7cd1a79e92700687f1e",
        :uncles_hash=>"0x0000000000000000000000000000000000000000000000000000000000000000",
        :version=>"0x0",
      }
    }
  end

  let(:uncle_template) { CKB::Types::UncleTemplate.from_h(uncle_template_h) }

  it "from_h" do
    expect(CKB::Types::UncleTemplate.from_h(uncle_template_h)).to be_a(CKB::Types::UncleTemplate)
  end

  it "uncle_template's attributes value should equal with block_template_h" do
    number_keys = %i(hash required proposals header)
    number_keys.each do |key|
      expect(uncle_template.to_h[key]).to eq uncle_template_h[key]
    end
  end

  it "to_h" do
    expect(
      uncle_template.to_h
    ).to eq uncle_template_h
  end
end
