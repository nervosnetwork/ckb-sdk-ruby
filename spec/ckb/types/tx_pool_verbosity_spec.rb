RSpec.describe CKB::Types::TxPoolVerbosity do
	let(:tx_pool_verbosity_h) do
		{
			:pending => {
				:"0xb9dfce5eacd8b9d5dadb20172d81795d05926f2bbf5774db40eabf0039a31803" => {:cycles => "0x19bab7", :size => "0x1d0", :fee => "0x258", :ancestors_size => "0x1d0", :ancestors_cycles => "0x19bab7", :ancestors_count => "0x1"},
				:"0x0a365f660592e22ba0aaad94fc4bda8d8522c3f33c473fc65c14645deab4c0bf" => {:cycles => "0x19bab7", :size => "0x1d0", :fee => "0x258", :ancestors_size => "0x1d0", :ancestors_cycles => "0x19bab7", :ancestors_count => "0x1"}
			},
			:proposed => {
				:"0x0a365f660592e22ba0aaad94fc4bda8d8522c3f33c473fc65c14645deab4c0bf" => {:cycles => "0x19bab7", :size => "0x1d0", :fee => "0x258", :ancestors_size => "0x1d0", :ancestors_cycles => "0x19bab7", :ancestors_count => "0x1"},
				:"0x6f14e3a5029c62c04c4447e736d7c9fb4907b0e479e9f163ca95baaad158fcc6" => {:cycles => "0x19bab7", :size => "0x1d0", :fee => "0x258", :ancestors_size => "0x1d0", :ancestors_cycles => "0x19bab7", :ancestors_count => "0x1"}
			},
		}
	end

	let(:tx_pool_verbosity) { CKB::Types::TxPoolVerbosity.from_h(tx_pool_verbosity_h) }

	it "from h" do
		expect(tx_pool_verbosity).to be_a(CKB::Types::TxPoolVerbosity)
		tx_pool_verbosity_h.each do |key, value|
			expect(tx_pool_verbosity.public_send(key).map { |k, v| [k, v.to_h] }.to_h).to eq value
		end
	end

	it "to_h" do
		expect(
			tx_pool_verbosity.to_h
		).to eq tx_pool_verbosity_h
	end
end