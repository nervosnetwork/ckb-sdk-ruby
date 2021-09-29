RSpec.describe CKB::AddressParser do
  let(:singlesig_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, hash_type: "type") }
  let(:multisig_script) { CKB::Types::Script.new(args: "0xf04cec84bc37f683613bed2f242c9aa1b678e9fe", code_hash: CKB::SystemCodeHash::SECP256K1_BLAKE160_MULTISIG_ALL_TYPE_HASH, hash_type: "type") }
  let(:full_data_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data") }
  let(:full_data_custom_args_script) { CKB::Types::Script.new(args: "0x23c329ed630d6ce750712a477543672adab57f699494", code_hash: "0xa656f172b6b45c245307aeb5a7a37a176f002f6f22e92582c58bf7ba362e4176", hash_type: "data") }
  let(:full_type_custom_code_hash_script) { CKB::Types::Script.new(args: "0x36c329ed630d6ce750712a477543672adab57f4c", code_hash: "0x1892ea40d82b53c678ff88312450bbb17e164d7a3e0a90941aa58839f56f8df2", hash_type: "type") }

  context "testnet mode" do
    let(:short_payload_singlesig_address) { "ckt1qyqrdsefa43s6m882pcj53m4gdnj4k440axqswmu83" }
    let(:short_payload_multisig_address) { "ckt1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lqh4kcuq" }
    let(:full_payload_data_address) { "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5czshhac" }
    let(:full_payload_custom_args_address) { "ckt1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvg7r98kkxrtvuag8z2j8w4pkw2k6k4lkn9y5sl04c6" }
    let(:full_payload_custom_code_hash_address) { "ckt1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5c02auef" }

    it "parse short payload singlesig address" do
      parsed_address = CKB::AddressParser.new(short_payload_singlesig_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq singlesig_script.args
      expect(parsed_address.script.code_hash).to eq singlesig_script.code_hash
      expect(parsed_address.script.hash_type).to eq singlesig_script.hash_type
      expect(parsed_address.address_type).to eq "SHORTSINGLESIG"
    end

    it "parse short payload multisig address" do
      parsed_address = CKB::AddressParser.new(short_payload_multisig_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq multisig_script.args
      expect(parsed_address.script.code_hash).to eq multisig_script.code_hash
      expect(parsed_address.script.hash_type).to eq multisig_script.hash_type
      expect(parsed_address.address_type).to eq "SHORTMULTISIG"
    end

    it "parse short payload acp address without minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a")
	    parsed_address = CKB::AddressParser.new("ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaq3xzhsz").parse
	    expect(parsed_address.mode).to eq CKB::MODE::TESTNET
	    expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse short payload acp address with ckb minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c")
      parsed_address = CKB::AddressParser.new("ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaqc9q8fqw").parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse short payload acp address with ckb and udt minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c01")
      parsed_address = CKB::AddressParser.new("ckt1qypylv479ewscx3ms620sv34pgeuz6zagaaqcqgr072sz").parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse full payload acp address with ckb and udt minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c0101")
      parsed_address = CKB::AddressParser.new("ckt1qs6pngwqn6e9vlm92th84rk0l4jp2h8lurchjmnwv8kq3rt5psf4vnajhch96rq68wrff7pjx59r8stgt4rh5rqpqy2a9ak4").parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse full payload data address" do
      parsed_address = CKB::AddressParser.new(full_payload_data_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq full_data_script.args
      expect(parsed_address.script.code_hash).to eq full_data_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_data_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse full payload custom args address" do
      parsed_address = CKB::AddressParser.new(full_payload_custom_args_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq full_data_custom_args_script.args
      expect(parsed_address.script.code_hash).to eq full_data_custom_args_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_data_custom_args_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse full payload custom code hash address" do
      parsed_address = CKB::AddressParser.new(full_payload_custom_code_hash_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq full_type_custom_code_hash_script.args
      expect(parsed_address.script.code_hash).to eq full_type_custom_code_hash_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_type_custom_code_hash_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse new full payload address" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_AGGRON, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c0101")
      parsed_address = CKB::AddressParser.new("ckt1qq6pngwqn6e9vlm92th84rk0l4jp2h8lurchjmnwv8kq3rt5psf4vq20k2lzuhgvrgacd98cxg6s5v7pdpw5w7svqyqscw4rzm").parse
      expect(parsed_address.mode).to eq CKB::MODE::TESTNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "should raise invalid format type error" do
      invalid_format_type_address = "ckt1q5qrdsefa43s6m882pcj53m4gdnj4k440axqr7p084"
      expect {
        CKB::AddressParser.new(invalid_format_type_address).parse
      }.to raise_error(CKB::AddressParser::InvalidFormatTypeError, "Invalid format type")
    end

    it "should raise invalid code hash index error" do
      invalid_code_hash_index_address = "ckt1qygndsefa43s6m882pcj53m4gdnj4k440axq009504"
      expect {
        CKB::AddressParser.new(invalid_code_hash_index_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashIndexError, "Invalid code hash index")
    end

    it "should raise invalid args size error" do
      invalid_args_address = "ckt1qyqz8sefa43s6m882pcj53m4gdnj4k440a5ef9qrw782c"
      expect {
        CKB::AddressParser.new(invalid_args_address).parse
      }.to raise_error(CKB::AddressParser::InvalidArgSizeError, "Short payload format address args bytesize must equal to 20")
    end

    it "should raise invalid code hash size error when code hash size is less than 32 without args" do
      invalid_code_hash_address = "ckt1qsyng32y"
      expect {
        CKB::AddressParser.new(invalid_code_hash_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32")
    end

    it "should raise invalid code hash size error when code hash size is less than 32 with args" do
      invalid_code_hash_address = "ckt1qjhsalswwkwvz"
      expect {
        CKB::AddressParser.new(invalid_code_hash_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32")
    end
  end

  context "mainnet mode" do
    let(:short_payload_singlesig_address) { "ckb1qyqrdsefa43s6m882pcj53m4gdnj4k440axqdt9rtd" }
    let(:short_payload_multisig_address) { "ckb1qyqlqn8vsj7r0a5rvya76tey9jd2rdnca8lq2sg8su" }
    let(:full_payload_data_address) { "ckb1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvdkr98kkxrtvuag8z2j8w4pkw2k6k4l5c0nw668" }
    let(:full_payload_custom_args_address) { "ckb1q2n9dutjk669cfznq7httfar0gtk7qp0du3wjfvzck9l0w3k9eqhvg7r98kkxrtvuag8z2j8w4pkw2k6k4lkn9y5q08kzs" }
    let(:full_payload_custom_code_hash_address) { "ckb1qsvf96jqmq4483ncl7yrzfzshwchu9jd0glq4yy5r2jcsw04d7xlydkr98kkxrtvuag8z2j8w4pkw2k6k4l5czfy37k" }

    it "parse short payload singlesig address" do
      parsed_address = CKB::AddressParser.new(short_payload_singlesig_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq singlesig_script.args
      expect(parsed_address.script.code_hash).to eq singlesig_script.code_hash
      expect(parsed_address.script.hash_type).to eq singlesig_script.hash_type
      expect(parsed_address.address_type).to eq "SHORTSINGLESIG"
    end

    it "parse short payload multisig address" do
      parsed_address = CKB::AddressParser.new(short_payload_multisig_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq multisig_script.args
      expect(parsed_address.script.code_hash).to eq multisig_script.code_hash
      expect(parsed_address.script.hash_type).to eq multisig_script.hash_type
      expect(parsed_address.address_type).to eq "SHORTMULTISIG"
    end

    it "parse short payload acp address without minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a")
      parsed_address = CKB::AddressParser.new("ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqvrugu7").parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse short payload acp address with ckb minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c")
      parsed_address = CKB::AddressParser.new("ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqcehzz9g").parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse short payload acp address with ckb and udt minimum limit" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c01")
      parsed_address = CKB::AddressParser.new("ckb1qypylv479ewscx3ms620sv34pgeuz6zagaaqcqgzc5xlw").parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "SHORTANYONECANPAY"
    end

    it "parse full payload data address" do
      parsed_address = CKB::AddressParser.new(full_payload_data_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq full_data_script.args
      expect(parsed_address.script.code_hash).to eq full_data_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_data_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse full payload custom args address" do
      parsed_address = CKB::AddressParser.new(full_payload_custom_args_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq full_data_custom_args_script.args
      expect(parsed_address.script.code_hash).to eq full_data_custom_args_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_data_custom_args_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse full payload custom code hash address" do
      parsed_address = CKB::AddressParser.new(full_payload_custom_code_hash_address).parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq full_type_custom_code_hash_script.args
      expect(parsed_address.script.code_hash).to eq full_type_custom_code_hash_script.code_hash
      expect(parsed_address.script.hash_type).to eq full_type_custom_code_hash_script.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "parse new full payload address" do
      acp_lock = CKB::Types::Script.new(code_hash: CKB::SystemCodeHash::ANYONE_CAN_PAY_CODE_HASH_ON_LINA, hash_type: "type", args: "0x4fb2be2e5d0c1a3b8694f832350a33c1685d477a0c0101")
      parsed_address = CKB::AddressParser.new("ckb1qrfkjktl73ljn77q637judm4xux3y59c29qvvu8ywx90wy5c8g34gq20k2lzuhgvrgacd98cxg6s5v7pdpw5w7svqyqsguej72").parse
      expect(parsed_address.mode).to eq CKB::MODE::MAINNET
      expect(parsed_address.script.args).to eq acp_lock.args
      expect(parsed_address.script.code_hash).to eq acp_lock.code_hash
      expect(parsed_address.script.hash_type).to eq acp_lock.hash_type
      expect(parsed_address.address_type).to eq "FULL"
    end

    it "should raise invalid encoding error when encoding is invalid" do
      expect do
        CKB::AddressParser.new("ckb1qrfkjktl73ljn77q637judm4xux3y59c29qvvu8ywx90wy5c8g34gqgqza8m903wt5xp5wuxjnurydg2x0qksh280gxqzqgdx3csx").parse
      end.to raise_error( CKB::AddressParser::InvalidEncodingError, "ckb2021 format full address must use bech32m encoding")
    end

    it "should raise invalid format type error" do
      invalid_format_type_address = "ckb1q5qrdsefa43s6m882pcj53m4gdnj4k440axq7mlstf"
      expect {
        CKB::AddressParser.new(invalid_format_type_address).parse
      }.to raise_error(CKB::AddressParser::InvalidFormatTypeError, "Invalid format type")
    end

    it "should raise invalid code hash index error" do
      invalid_code_hash_index_address = "ckb1qygndsefa43s6m882pcj53m4gdnj4k440axqj2mtrf"
      expect {
        CKB::AddressParser.new(invalid_code_hash_index_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashIndexError, "Invalid code hash index")
    end

    it "should raise invalid prefix error" do
      invalid_prefix_address = "haha1qygndsefa43s6m882pcj53m4gdnj4k440axqsm2hnz"
      expect {
        CKB::AddressParser.new(invalid_prefix_address).parse
      }.to raise_error(CKB::AddressParser::InvalidPrefixError, "Invalid prefix")
    end

    it "should raise invalid args size error" do
      invalid_args_address = "ckb1qyqz8sefa43s6m882pcj53m4gdnj4k440a5ef9qze5t95"
      expect {
        CKB::AddressParser.new(invalid_args_address).parse
      }.to raise_error(CKB::AddressParser::InvalidArgSizeError, "Short payload format address args bytesize must equal to 20")
    end

    it "should raise invalid code hash size error when code hash size is less than 32 without args" do
      invalid_code_hash_address = "ckb1qspk2ff3"
      expect {
        CKB::AddressParser.new(invalid_code_hash_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32")
    end

    it "should raise invalid code hash size error when code hash size is less than 32 with args" do
      invalid_code_hash_address = "ckb1qjhsals8zkecn"
      expect {
        CKB::AddressParser.new(invalid_code_hash_address).parse
      }.to raise_error(CKB::AddressParser::InvalidCodeHashSizeError, "CodeHash bytesize must equal to 32")
    end
  end
end
