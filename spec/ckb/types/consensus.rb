RSpec.describe CKB::Types::Consensus do
	let(:consensus_h) do
		{
			:block_version=>"0x0",
			:cellbase_maturity=>"0x10000000000",
		  :dao_type_hash=>"0x82d76d1b75fe2fd9a27dfbaa65a039221a380d76c926f378d3f81cf3e7e13f2e",
		  :epoch_duration_target=>"0x3840",
		  :genesis_hash=>"0x823b2ff5785b12da8b1363cac9a5cbe566d8b715a4311441b119c39a0367488c",
		  :id=>"ckb_dev",
		  :initial_primary_epoch_reward=>"0xae6c73c3e070",
		  :max_block_bytes=>"0x91c08",
		  :max_block_cycles=>"0x2540be400",
		  :max_block_proposals_limit=>"0x5dc",
		  :max_uncles_num=>"0x2",
		  :median_time_block_count=>"0x25",
		  :orphan_rate_target=>{:denom=>"0x28", :numer=>"0x1"},
		  :permanent_difficulty_in_dummy=>false,
		  :primary_epoch_reward_halving_interval=>"0x2238",
		  :proposer_reward_ratio=>{:denom=>"0xa", :numer=>"0x4"},
		  :secondary_epoch_reward=>"0x37d0c8e28542",
		  :secp256k1_blake160_multisig_all_type_hash=>"0x5c5069eb0857efc65e1bca0c07df34c31663b3622fd3876c876320fc9634e2a8",
		  :secp256k1_blake160_sighash_all_type_hash=>"0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
		  :tx_proposal_window=>{:closest=>"0x2", :farthest=>"0xa"},
		  :tx_version=>"0x0",
		  :type_id_code_hash=>"0x00000000000000000000000000000000000000000000000000545950455f4944"
		}
	end

	let(:consensus) { CKB::Types::Consensus.from_h(consensus_h) }

	it "from h" do
		expect(consensus).to be_a(CKB::Types::Consensus)
		expect(consensus.id).to eq consensus_h[:id]
		expect(consensus.genesis_hash).to eq consensus_h[:genesis_hash]
		expect(consensus.dao_type_hash).to eq consensus_h[:dao_type_hash]
		expect(consensus.secp256k1_blake160_sighash_all_type_hash).to eq consensus_h[:secp256k1_blake160_sighash_all_type_hash]
		expect(consensus.secp256k1_blake160_multisig_all_type_hash).to eq consensus_h[:secp256k1_blake160_multisig_all_type_hash]
		expect(CKB::Utils.to_hex(consensus.initial_primary_epoch_reward)).to eq consensus_h[:initial_primary_epoch_reward]
		expect(CKB::Utils.to_hex(consensus.secondary_epoch_reward)).to eq consensus_h[:secondary_epoch_reward]
		expect(CKB::Utils.to_hex(consensus.max_uncles_num)).to eq consensus_h[:max_uncles_num]
		expect(consensus.orphan_rate_target.to_h).to eq consensus_h[:orphan_rate_target]
		expect(CKB::Utils.to_hex(consensus.epoch_duration_target)).to eq consensus_h[:epoch_duration_target]
		expect(consensus.tx_proposal_window.to_h).to eq consensus_h[:tx_proposal_window]
		expect(consensus.proposer_reward_ratio.to_h).to eq consensus_h[:proposer_reward_ratio]
		expect(consensus.cellbase_maturity).to eq consensus_h[:cellbase_maturity]
		expect(CKB::Utils.to_hex(consensus.max_block_cycles)).to eq consensus_h[:max_block_cycles]
		expect(CKB::Utils.to_hex(consensus.max_block_bytes)).to eq consensus_h[:max_block_bytes]
		expect(CKB::Utils.to_hex(consensus.block_version)).to eq consensus_h[:block_version]
		expect(CKB::Utils.to_hex(consensus.tx_version)).to eq consensus_h[:tx_version]
		expect(consensus.type_id_code_hash).to eq consensus_h[:type_id_code_hash]
		expect(CKB::Utils.to_hex(consensus.max_block_proposals_limit)).to eq consensus_h[:max_block_proposals_limit]
		expect(CKB::Utils.to_hex(consensus.primary_epoch_reward_halving_interval)).to eq consensus_h[:primary_epoch_reward_halving_interval]
		expect(consensus.permanent_difficulty_in_dummy).to eq consensus_h[:permanent_difficulty_in_dummy]
	end

	it "to_h" do
		expect(
			consensus.to_h
		).to eq consensus_h
	end
end
