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
      ).to eq "ckt1qq6pngwqn6e9vlm92th84rk0l4jp2h8lurchjmnwv8kq3rt5psf4vq20k2lzuhgvrgacd98cxg6s5v7pdpw5w7svqyqscw4rzm"
    end

    it "generate full 2019 format payload data address" do
      address = CKB::Address.new(full_data_script, version: CKB::Address::Version::CKB2019)
      expect(
        address.generate
      ).to eq "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5czshhac"
    end

    it "generate full payload data address" do
      script = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", hash_type: "type", args: "0xb39bbc0b3673c7d36450bc14cfcdad2d559c6c64")
      address = CKB::Address.new(script)
      expect(
        address.send(:generate_full_payload_address)
      ).to eq "ckt1qzda0cr08m85hc8jlnfp3zer7xulejywt49kt2rr0vthywaa50xwsqdnnw7qkdnnclfkg59uzn8umtfd2kwxceqgutnjd"
    end

    it "generate full payload custom args address" do
      address = CKB::Address.new(full_data_custom_args_script)
      expect(
        address.generate
      ).to eq "ckt1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqprcv576ccddnn4quf2ga65xee2m26h76v5jsxp7k74"
    end

    it "generate full payload custom code hash address" do
      address = CKB::Address.new(full_type_custom_code_hash_script)
      expect(
        address.generate
      ).to eq "ckt1qqvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlyqfkcv576ccddnn4quf2ga65xee2m26h7nq8t420m"
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

    it "generate full payload data1 address" do
      script = CKB::Types::Script.new(code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data1", args: "0xb39bbc0b3673c7d36450bc14cfcdad2d559c6c64")
      address = CKB::Address.new(script)
      expect(
        address.generate
      ).to eq "ckt1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvq4nnw7qkdnnclfkg59uzn8umtfd2kwxceq225jvu"
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
      ).to eq "ckb1qrfkjktl73ljn77q637judm4xux3y59c29qvvu8ywx90wy5c8g34gq20k2lzuhgvrgacd98cxg6s5v7pdpw5w7svqyqsguej72"
    end

    it "generate full 2019 format payload data address" do
      address = CKB::Address.new(full_data_script, mode: CKB::MODE::MAINNET, version: CKB::Address::Version::CKB2019)
      expect(
        address.generate
      ).to eq "ckb1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5c0nw668"
    end

    it "generate full payload data address" do
      script = CKB::Types::Script.new(code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8", hash_type: "type", args: "0xb39bbc0b3673c7d36450bc14cfcdad2d559c6c64")
      address = CKB::Address.new(script, mode: CKB::MODE::MAINNET)
      expect(
        address.send(:generate_full_payload_address)
      ).to eq "ckb1qzda0cr08m85hc8jlnfp3zer7xulejywt49kt2rr0vthywaa50xwsqdnnw7qkdnnclfkg59uzn8umtfd2kwxceqxwquc4"
    end

    it "generate full payload custom args address" do
      address = CKB::Address.new(full_data_custom_args_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvqprcv576ccddnn4quf2ga65xee2m26h76v5jsak26la"
    end

    it "generate full payload custom code hash address" do
      address = CKB::Address.new(full_type_custom_code_hash_script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qqvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlyqfkcv576ccddnn4quf2ga65xee2m26h7nqfe799r"
    end

    it "raise error when mode is invalid" do
      expect do
        address = CKB::Address.new(full_data_custom_args_script, mode: "haha")
        address.generate
      end.to raise_error(CKB::Address::InvalidModeError, "Invalid mode")
    end

    it "generate full payload data1 address" do
      script = CKB::Types::Script.new(code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data1", args: "0xb39bbc0b3673c7d36450bc14cfcdad2d559c6c64")
      address = CKB::Address.new(script, mode: CKB::MODE::MAINNET)
      expect(
        address.generate
      ).to eq "ckb1qzn9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvq4nnw7qkdnnclfkg59uzn8umtfd2kwxceqyclaxy"
    end
  end
end
