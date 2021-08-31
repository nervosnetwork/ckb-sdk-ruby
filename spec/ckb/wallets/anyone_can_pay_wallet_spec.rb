require 'pry'
RSpec.describe CKB::Wallets::AnyoneCanPayWallet do
  # deploy anyone can pay and get tx hash
  # ```
  # api = CKB::API.new
  # w_m = CKB::Wallet.from_hex(api, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")
  # wallet = CKB::Wallets::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
  # args = CKB::Utils.bin_to_hex("\x00" * 32)
  # data = CKB::Utils.bin_to_hex(File.read("/your-path-to/anyone_can_pay"))
  # tg = wallet.generate(w_m.address, 500000*10**8, { data: data, type: CKB::Types::Script.new(code_hash: "0x00000000000000000000000000000000000000000000000000545950455f4944", hash_type: "type", args: args) })
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
  # out_point_vec_serializer = CKB::Serializers::FixVecSerializer.new(out_points, CKB::Serializers::OutPointSerializer)
  # dep_group_cell_data = out_point_vec_serializer.serialize
  # tg1 = wallet.generate(w_m.address, 1000*10**8, { data: dep_group_cell_data })
  # tx1 = wallet.sign(tg1, "0x84ffe5a2b82ac1fbc7960a93ac6ed06fecf0271dd959bbcec5eeeafcc3e8e53f")
  # api.send_transaction(tx1)

  before do
    skip "not test rpc" if ENV["SKIP_RPC_TESTS"]
    config = CKB::Config.instance
    config.set_api(CKB::RPC::DEFAULT_URL)
    # This is my locally deployed sudt type script's code hash and tx hash. This code hash and tx hash will be replaced after the real sudt type script deployed on mainnet in the future
    config.sudt_info = { code_hash: "0x5e7a36a77e68eecc013dfa2fe6a23f3b6c344b04005808694ae6dd45eea4cfd5", tx_hash: "0xc7813f6a415144643970c2e88e0bb6ca6a8edc5dd7c1022746f628284a9936d5", hash_type: "type" }
    # This is my locally deployed anyone can pay lock script's code hash and tx hash. This code hash and tx hash will be replaced after the real anyone can pay lock script deployed on mainnet in the future
    config.anyone_can_pay_info = { code_hash: "0x0fb343953ee78c9986b091defb6252154e0bb51044fd2879fde5b27314506111", tx_hash: "0xa05f28c9b867f8c5682039c10d8e864cf661685252aa74a008d255c33813bb81" }
    config.type_handlers[[config.sudt_info[:code_hash], CKB::Config::TYPE]] = CKB::TypeHandlers::SudtHandler.new(config.sudt_info[:tx_hash])
    config.lock_handlers[[config.anyone_can_pay_info[:code_hash], CKB::Config::DATA]] = CKB::LockHandlers::AnyoneCanPayHandler.new(config.anyone_can_pay_info[:tx_hash])
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
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: ["ckb1qg8mxsu48mncexvxkzgaa7mz2g25uza4zpz062relhjmyuc52ps3r55nna966c84sy3tuuqj4nkajf47dpqfgnhjlgu", "ckb1qyqd9yulfwkkpavpy2l8qy4vahvjd0nggz2qhv848u"], anyone_can_pay_addresses: "ckb1qg8mxsu48mncexvxkzgaa7mz2g25uza4zpz062relhjmyuc52ps3r55nna966c84sy3tuuqj4nkajf47dpqfgnhjlgu", sudt_args: "0x278e9c538c354bd3ca7872799d330e8a9ff932351d191ff68a2517f2208a4c81", mode: "mainnet", from_block_number: 2626685, collector_type: :indexer)
    tx_generator = anyone_can_pay_wallet.generate("ckb1qg8mxsu48mncexvxkzgaa7mz2g25uza4zpz062relhjmyuc52ps3r55nna966c84sy3tuuqj4nkajf47dpqfgnhjlgu", { type: :ckb, amount: CKB::Utils.byte_to_shannon(1) })
    tx = anyone_can_pay_wallet.advance_sign(tx_generator: tx_generator, contexts: [nil, "0x144188b5b00c9758c6543c97f98ba6d591b2d5abddf3ff83f6001d608565604b"])

    expect(api.send_transaction(tx)).not_to be_nil
  end

  # need pass context to generate method when use signature to unlock a anyone can pay cell
  it "transfer udt with signature" do
    sudt_args = "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947"
    sudt_type_script = CKB::Types::Script.new(code_hash: CKB::Config.instance.sudt_info[:code_hash], args: sudt_args, hash_type: "data")
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", { type: :udt, amount: 10000 }, { type: sudt_type_script, context: "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  it "transfer ckb with signature" do
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", anyone_can_pay_addresses: "ckt1qnqmwcl089v0m32s969cc0ud5d62qs0jx8kq36s2vh95ehgjtxdt6kdz0mem4p8sv9gh6yl59n6ya5pqvyqxznkgfxa", sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate("ckt1qyqqg2rcmvgwq9ypycgqgmp5ghs3vcj8vm0s2ppgld", { type: :ckb, amount: CKB::Utils.byte_to_shannon(100) }, { context: "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x2a7ba51e4f02fac14b6fef7ac185cd62d9826e333b6a04ecc4ae702bdbf429d3")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  # need generate anyone can pay cell first
  # alice_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0xe1784c9d961e019c1c38a610385114b7fa66d636", hash_type: "type")).generate
  # bob_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0x18ae19f1eca64344a9af3d65aef8699f84447869", hash_type: "type")).generate
  # wallet = CKB::Wallets::NewWallet.new(api: api, from_addresses: "ckt1qyqvsv5240xeh85wvnau2eky8pwrhh4jr8ts8vyj37")
  # sudt_args = "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947"
  # sudt_type_script = CKB::Types::Script.new(code_hash: CKB::Config.instance.sudt_info[:code_hash], args: sudt_args, hash_type: "data")

  # tx_generator = wallet.advance_generate(
  #   to_infos: {
  #     alice_anyone_can_pay_address => { capacity: CKB::Utils.byte_to_shannon(1000), type: sudt_type_script, data: "0x#{'0' * 32}" },
  #     bob_anyone_can_pay_address => { capacity: CKB::Utils.byte_to_shannon(1000), type: sudt_type_script, data: "0x#{'0' * 32}" }
  #   }
  # )
  # tx = wallet.sign(tx_generator, "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc")
  it "transfer ckb from anyone can pay wallet A to anyone can pay wallet B" do
    alice_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0xe1784c9d961e019c1c38a610385114b7fa66d636", hash_type: "type")).generate
    bob_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0x18ae19f1eca64344a9af3d65aef8699f84447869", hash_type: "type")).generate
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: alice_anyone_can_pay_address, anyone_can_pay_addresses: [alice_anyone_can_pay_address, bob_anyone_can_pay_address], sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate(bob_anyone_can_pay_address, { type: :ckb, amount: CKB::Utils.byte_to_shannon(100) }, { context: "0x133f4ee97e74c0c103c79a914b28ec491434a582434a3ad30f9619e7d032083d" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x133f4ee97e74c0c103c79a914b28ec491434a582434a3ad30f9619e7d032083d")

    expect(api.send_transaction(tx)).not_to be_nil
  end

  # need prepare some udt in alice anyone can pay wallet
  it "transfer sudt from anyone can pay wallet A to anyone can pay wallet B" do
    sudt_args = "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947"
    sudt_type_script = CKB::Types::Script.new(code_hash: CKB::Config.instance.sudt_info[:code_hash], args: sudt_args, hash_type: "data")
    alice_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0xe1784c9d961e019c1c38a610385114b7fa66d636", hash_type: "type")).generate
    bob_anyone_can_pay_address = CKB::Address.new(CKB::Types::Script.new(code_hash: "0xc1b763ef3958fdc5502e8b8c3f8da374a041f231ec08ea0a65cb4cdd12599abd", args: "0x18ae19f1eca64344a9af3d65aef8699f84447869", hash_type: "type")).generate
    anyone_can_pay_wallet = CKB::Wallets::AnyoneCanPayWallet.new(api: api, from_addresses: alice_anyone_can_pay_address, anyone_can_pay_addresses: [alice_anyone_can_pay_address, bob_anyone_can_pay_address], sudt_args: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947")
    tx_generator = anyone_can_pay_wallet.generate(bob_anyone_can_pay_address, { type: :udt, amount: 1000 }, { type: sudt_type_script, context: "0x133f4ee97e74c0c103c79a914b28ec491434a582434a3ad30f9619e7d032083d" })
    tx = anyone_can_pay_wallet.sign(tx_generator, "0x133f4ee97e74c0c103c79a914b28ec491434a582434a3ad30f9619e7d032083d")

    expect(api.send_transaction(tx)).not_to be_nil
  end
end
