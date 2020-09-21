RSpec.describe CKB::Wallets::SudtWallet do
  # deploy sudt and get tx hash
  # ```
  # api = CKB::API.new
  # wallet = CKB::Wallets::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
  # data = CKB::Utils.bin_to_hex(File.read("/your-path-to/ckb-minimal-udt/src/udt"))
  # tx_generator = wallet.generate("ckt1qgqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqparrr6", 50000*10**8, {data: data})
  # tx = wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")
  # api.send_transaction(tx)
  # ```
  # => 0x0f18ac6058f7e1cef8a94b4709be58077aef1ad586403c4337226af3fb12ba29
  #

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
    config = CKB::Config.instance
    config.set_api(CKB::RPC::DEFAULT_URL)
    # This is my locally deployed sudt type script's code hash and tx hash. This code hash and tx hash will be replaced after the real sudt type script deployed on mainnet in the future
    config.sudt_info = { code_hash: "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212", tx_hash: "0x0f18ac6058f7e1cef8a94b4709be58077aef1ad586403c4337226af3fb12ba29", hash_type: "type" }
    config.type_handlers[[config.sudt_info[:code_hash], CKB::Config::DATA]] = CKB::TypeHandlers::SudtHandler.new(config.sudt_info[:tx_hash])
  end

  let(:api) { CKB::API.new }

  # `0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947`
  it "sudt issue" do
    sudt_wallet = CKB::Wallets::SudtWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    # issue 100_0000 sudt to `ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld`
    tx_generator = sudt_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", 100_0000)
    tx = sudt_wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")

    expect(api.send_transaction(tx)).not_to be_nil
  end


  it "sudt transfer" do
    sudt_wallet = CKB::Wallets::SudtWallet.new(api: api, from_addresses: "ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    # transfer 1000 sudt to `ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6`
    tx_generator = sudt_wallet.generate("ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6", 1000)
    tx = sudt_wallet.sign(tx_generator, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "sudt burn" do
    # burn 100 sudt from `ckt1qyq9ngn77wagfurp29738apv738dqgrpqpssfhr0l6`
    burn_amount = 1000
    sudt_wallet = CKB::Wallets::SudtWallet.new(api: api, from_addresses: "ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    total_amount = sudt_wallet.total_amount
    tx_generator = sudt_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", total_amount)
    after_burn_amount = total_amount - burn_amount
    tx_generator.transaction.outputs_data[0] = CKB::Utils.generate_sudt_amount(after_burn_amount)
    tx = sudt_wallet.sign(tx_generator, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f")

    expect(api.send_transaction(tx)).not_to be_nil
  end
end
