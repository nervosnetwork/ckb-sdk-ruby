RSpec.describe CKB::Types::TxVerbosity do
	let(:tx_verbosity_h) do
		{:cycles => "0x19bab7", :size => "0x1d0", :fee => "0x258", :ancestors_size => "0x1d0", :ancestors_cycles => "0x19bab7", :ancestors_count => "0x1"}
	end

	let(:tx_verbosity) { CKB::Types::TxVerbosity.from_h(tx_verbosity_h) }

	it "from h" do
		expect(tx_verbosity).to be_a(CKB::Types::TxVerbosity)
		tx_verbosity_h.each do |key, value|
			expect(tx_verbosity.public_send(key)).to eq CKB::Utils.to_int(value)
		end
	end

	it "to_h" do
		expect(
			tx_verbosity.to_h
		).to eq tx_verbosity_h
	end
end