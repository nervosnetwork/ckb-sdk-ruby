RSpec.describe CKB::NewWallet do
  # addresses `ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37` / `ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4`
  # and corresponding private keys are copied from dev chain genesis block's issued_cells:
  # https://github.com/nervosnetwork/ckb/blob/develop/resource/specs/dev.toml#L70
  #
  # addresses `ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld` / `ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6`
  # and corresponding private keys are randomly generated by sdk:
  # `0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f` / `0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3`

  # `ckt1qyq72ua6khnkfqzt5wmhmrxmh54a4arwarfsncdxuc` is a multisig address generated by
  # ./ckb-cli tx build-multisig-address --sighash-address ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37 --sighash-address ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4 --sighash-address ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld --threshold 2
  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
  end

  let(:api) { CKB::API.new }

  it "generate transaction by default scanner" do
    wallet = CKB::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
    tx_generator = wallet.generate("ckt1qyq72ua6khnkfqzt5wmhmrxmh54a4arwarfsncdxuc", CKB::Utils.byte_to_shannon(1000))
    tx = wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  # enable `Indexer` module in ckb.toml `rpc` section
  # and index with lock hash by rpc first:
  # api.index_lock_hash("0xc219351b150b900e50a7039f1e448b844110927e5fd9bd30425806cb8ddff1fd")
  it "generate transaction by default indexer" do
    wallet = CKB::NewWallet.new(api: api, from_addresses: "ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4", collector_type: :default_indexer)
    tx_generator = wallet.generate("ckt1qyq72ua6khnkfqzt5wmhmrxmh54a4arwarfsncdxuc", CKB::Utils.byte_to_shannon(1000))
    tx = wallet.sign(tx_generator, "0x63d86723e08f0f813a36ce6aa123bb2289d90680ae1e99d4de8cdb334553f24d")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "generate transaction via advance_generate" do
    wallet = CKB::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
    tx_generator = wallet.advance_generate(
      to_infos: {
        "ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld" => { capacity: CKB::Utils.byte_to_shannon(1000) },
        "ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6" => { capacity: CKB::Utils.byte_to_shannon(2000) }
       },
       fee_rate: 2
    )
    tx = wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "use advance sign" do
    wallet = CKB::NewWallet.new(api: api, from_addresses: ["ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", "ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6"])
    tx_generator = wallet.generate("ckt1qyq72ua6khnkfqzt5wmhmrxmh54a4arwarfsncdxuc", CKB::Utils.byte_to_shannon(200))
    tx = wallet.advance_sign(tx_generator: tx_generator, contexts: ["0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f", "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3"])

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "generate multisig transaction" do
    wallet = CKB::NewWallet.new(api: api, from_addresses: "ckt1qyq72ua6khnkfqzt5wmhmrxmh54a4arwarfsncdxuc")
    # build tx to transfer 200 ckb from a 2 / 3 multisig script address
    tx_generator = wallet.generate("ckt1qyqywrwdchjyqeysjegpzw38fvandtktdhrs0zaxl4", CKB::Utils.byte_to_shannon(200), { context: [0, 0, 2, 3, "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7", "0x470dcdc5e44064909650113a274b3b36aecb6dc7", "0x042878db10e014812610046c3445e116624766df"] })
    # sign with two private keys
     # equivalent to `tx = wallet.advance_sign(tx_builder, [private_key1, private_key2])`
    wallet.sign(tx_generator, ["0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc"])
    tx = wallet.sign(tx_generator, ["0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f"])

    expect(api.send_transaction(tx)).not_to be_nil
  end
end