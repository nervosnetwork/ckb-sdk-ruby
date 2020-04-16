require 'pry'
RSpec.describe CKB::Wallets::AnyoneCanPayWallet do
  # deploy anyone can pay and get tx hash
  # ```
  # api = CKB::API.new
  # w_m = CKB::Wallet.from_hex(api, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")
  # wallet = CKB::Wallets::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
  # args = CKB::Utils.bin_to_hex("\x00" * 32)
  # data = CKB::Utils.bin_to_hex(File.read("/your-path-to/anyone_can_pay"))
  # tg = wallet.generate(w_m.address, 500000*10**8, { data: data1, type: CKB::Types::Script.new(code_hash: "0x00000000000000000000000000000000000000000000000000545950455f4944", hash_type: "type", args: args) })
  # tx = tg.transaction
  # serializer = CKB::Serializers::InputSerializer.new(tx.inputs.first)
  # blake2b = CKB::Blake2b.new
  # blake2b.update(CKB::Utils.hex_to_bin(serializer.serialize))
  # blake2b.update([0].pack("Q<"))
  # args = blake2b.hexdigest
  # tx.outputs.first.type.args = args
  # tx = wallet.sign(tg, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f")
  # api.send_transaction(tx) => 0x34bd494353ddcacf5a9c8a434a1563d7fb55306c4f9888413c3cac5b770d5845
  # ```
  #
  # deploy group cell
  # out_points = [CKB::Types::OutPoint.new(tx_hash: "0x34bd494353ddcacf5a9c8a434a1563d7fb55306c4f9888413c3cac5b770d5845", index: 0), api.secp_data_out_point]
  # out_point_vev_serializer = CKB::Serializers::FixVecSerializer.new(out_points, CKB::Serializers::OutPointSerializer)
  # dep_group_cell_data = out_point_vev_serializer.serialize
  # tg1 = w.generate(w_m.address, 1000*10**8, { data: dep_group_cell_data })
  # tx1 = w.sign(tg1, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f")
  # api.send_transaction(tx1)

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
    config = CKB::Config.instance
    # This is my locally deployed sudt type script's code hash and tx hash. This code hash and tx hash will be replaced after the real sudt type script deployed on mainnet in the future
    config.sudt_info = { code_hash: "0x48dbf59b4c7ee1547238021b4869bceedf4eea6b43772e5d66ef8865b6ae7212", tx_hash: "0x0f18ac6058f7e1cef8a94b4709be58077aef1ad586403c4337226af3fb12ba29" }
    # This is my locally deployed anyone can pay lock script's code hash and tx hash. This code hash and tx hash will be replaced after the real anyone can pay lock script deployed on mainnet in the future
    config.anyone_can_pay_info = { code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", tx_hash: "0xeba5986c50e7e8215c2acd6501150cab1346119f42f4d7870bfadd5bfdf7fe57" }
    config.type_handlers[[config.sudt_info[:code_hash], CKB::Config::DATA]] = CKB::TypeHandlers::SudtHandler.new(config.sudt_info[:tx_hash])
    config.lock_handlers[[config.anyone_can_pay_info[:code_hash], CKB::Config::TYPE]] = CKB::LockHandlers::AnyoneCanPayHandler.new(config.anyone_can_pay_info[:tx_hash])
  end

  let(:api) { CKB::API.new }

  # `anyone can pay code hash: 0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd`
  it "generate anyone can pay cell" do
    anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0x59a27ef3ba84f061517d13f42cf44ed020610061", hash_type: "type")).generate
    wallet = CKB::Wallets::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
    sudt_args = "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947"
    sudt_type_script = CKB::Types::Script.new(code_hash: CKB::Config.instance.sudt_info[:code_hash], args: sudt_args, hash_type: "data")

    tx_generator = wallet.advance_generate(
      to_infos: {
        anyone_can_pay_address => { capacity: CKB::Utils.byte_to_shannon(1000), type: sudt_type_script, data: "0x#{'0' * 32}"}
      }
    )
    tx = wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "transfer udt without signature" do
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: ["ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", "ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld"], anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", { type: :udt, amount: 10000 })
    tx = anyone_can_pay_wallet.advance_sign(tx_generator: tx_generator, contexts: [nil, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f"])

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "transfer ckb without signature" do
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: ["ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", "ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld"], anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", { type: :ckb, amount: CKB::Utils.byte_to_shannon(100) })
    tx = anyone_can_pay_wallet.advance_sign(tx_generator: tx_generator, contexts: [nil, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f"])

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "transfer udt with signature" do
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", { type: :udt, amount: 10000 }, { data: "0x#{'0' * 32}", context: "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "transfer ckb with signature" do
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", { type: :ckb, amount: CKB::Utils.byte_to_shannon(100) }, { context: "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")

    expect(api.send_transaction(tx)).not_to be_nil
  end
end
