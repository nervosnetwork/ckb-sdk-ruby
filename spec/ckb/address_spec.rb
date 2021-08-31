require 'pry'
RSpec.describe CKB::Address do
  let(:singlesig_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, hash_type: "type") }
  let(:multisig_script) { CKB::Types::Script.new(args: "0xf04cec84bc37f683613bed2f242c9aa1b678e9fe", code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, hash_type: "type") }
  let(:full_data_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data") }
  let(:full_data_custom_args_script) { CKB::Types::Script.new(args: "0x23c329ed630d6ce750712a477543672adab57f699494", code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data") }
  let(:full_type_custom_code_hash_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: "0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2", hash_type: "type") }

  context "testnet mode" do
    it "generate short payload singlesig address" do
      addr = CKB::Address.new(singlesig_script)
      expect(
        addr.to_s
      ).to eq "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83"
    end

    it "generate short payload multisig address" do
      address = CKB::Address.new(multisig_script)
      expect(
        address.generate
      ).to eq "ckt1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lqh4kcuq"
    end

    it "generate short payload anyone can pay address without minimum limit" do
	    acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a")
	    address = CKB::Address.new(acp_lock)
	    expect(
		    address.generate
	    ).to eq "ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaq3xzhsz"
    end

    it "generate short payload anyone can pay address with ckb minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c")
      address = CKB::Address.new(acp_lock)
      expect(
        address.generate
      ).to eq "ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaqc9q8fqw"
    end

    it "generate short payload anyone can pay address with ckb and udt minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c01")
      address = CKB::Address.new(acp_lock)
      expect(
        address.generate
      ).to eq "ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaqcqgr072sz"
    end

    it "generate full payload address when acp lock args is more than 22 bytes" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c0101")
      address = CKB::Address.new(acp_lock)
      expect(
        address.generate
      ).to eq "ckt1qq6pngwqn6e9vlm92th84rk0l4jp2h8lurchjmnwv8kq3rt5psf4vqgqza8m903wt5xp5wuxjnurydg2x0qksh280gxqzqgutrqyp"
    end

    it "generate full payload data address" do
      address = CKB::Address.new(full_data_script)
      expect(
        address.generate
      ).to eq "ckt1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqqqzsmvx20dvvxkee6swy4ywa2rvu4d4dtlfs62pmzq"
    end

    it "generate full payload custom args address" do
      address = CKB::Address.new(full_data_custom_args_script)
      expect(
        address.generate
      ).to eq "ckt1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqqqzc3ux20dvvxkee6swy4ywa2rvu4d4dtldx2fgsfkplx"
    end

    it "generate full payload custom code hash address" do
      address = CKB::Address.new(full_type_custom_code_hash_script)
      expect(
        address.generate
      ).to eq "ckt1qqvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlyqgqzsmvx20dvvxkee6swy4ywa2rvu4d4dtlfsmq4jle"
    end

    it "raise error when mode is invalid" do
      expect do
        address = CKB::Address.new(full_data_custom_args_script, mode: "haha")
        address.generate
      end.to raise_error(CKB::Address::InvalidModeError, "Invalid mode")
    end

    it "should generate full payload address when there are no args" do
      expect do
        script = CKB::Types::Script.new(code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", args: "", hash_type: "type")
        CKB::Address.new(script).generate
      end.not_to raise_error
    end

    it "should generate current version full payload address" do
      expect do
        script = CKB::Types::Script.new(code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c", hash_type: "data1")
        CKB::Address.new(script).generate
      end.not_to raise_error
    end
  end

  context "mainnet mode" do
    it "generate short payload singlesig address" do
      addr = CKB::Address.new(singlesig_script, mode: CKB::MODE::MAINNET)
      expect(
        addr.to_s
      ).to eq "ckb1qyqrdsefa43s6m882pcj53m4gdnj4k440axqdt9rtd"
    end

    it "generate short payload multisig address" do
      address = CKB::Address.new(multisig_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lq2sg8su"
    end

    it "generate short payload anyone can pay address without minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a")
      address = CKB::Address.new(acp_lock, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqvrugu7"
    end

    it "generate short payload anyone can pay address with ckb minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c")
      address = CKB::Address.new(acp_lock, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqcehzz9g"
    end

    it "generate short payload anyone can pay address with ckb and udt minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c01")
      address = CKB::Address.new(acp_lock, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqcqgzc5xlw"
    end

    it "generate full payload address when acp lock args is more than 22 bytes" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c0101")
      address = CKB::Address.new(acp_lock, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qrfkjktl73ljn77q637judm4xux3y59c29qvvu8ywx90wy5c8g34gqgqza8m903wt5xp5wuxjnurydg2x0qksh280gxqzqgdx3csx"
    end

    it "generate full payload data address" do
      address = CKB::Address.new(full_data_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqqqzsmvx20dvvxkee6swy4ywa2rvu4d4dtlfspa4hrg"
    end

    it "generate full payload custom args address" do
      address = CKB::Address.new(full_data_custom_args_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqqqzc3ux20dvvxkee6swy4ywa2rvu4d4dtldx2fgmg2gm0"
    end

    it "generate full payload custom code hash address" do
      address = CKB::Address.new(full_type_custom_code_hash_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qqvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlyqgqzsmvx20dvvxkee6swy4ywa2rvu4d4dtlfsqhp773"
    end

    it "raise error when mode is invalid" do
      expect do
        address = CKB::Address.new(full_data_custom_args_script, mode: "haha")
        address.generate
      end.to raise_error(CKB::Address::InvalidModeError, "Invalid mode")
    end
  end
end
