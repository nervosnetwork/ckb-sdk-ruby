# ckb-sdk-ruby

[![Build Status](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby.svg?branch=develop)](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby)

Ruby SDK for CKB

## Prerequisites

Require Ruby 2.4 and above.

Please be noted that the SDK depends on the [bitcoin-secp256k1](https://github.com/cryptape/ruby-bitcoin-secp256k1) gem and the [rbnacl](https://github.com/crypto-rb/rbnacl) gem, which require manual install of secp256k1 and libsodium library. Follow [this](https://github.com/cryptape/ruby-bitcoin-secp256k1#prerequisite) and [this](https://github.com/crypto-rb/rbnacl#installation) to install them locally.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckb-sdk-ruby', github: 'nervosnetwork/ckb-sdk-ruby', require: 'ckb'
```

And then execute:

    $ bundle

## Usage

RPC interface returns parsed `JSON` object

```ruby
rpc = CKB::RPC.new

# using RPC `get_tip_header`, it will return a Hash
rpc.get_tip_header
```

API interface returns `Types` instead of `Hash`

```ruby
api = CKB::API.new

# it will return a CKB::Types::BlockHeader
api.get_tip_header
```

Send capacity

```ruby
# create api first
api = CKB::API.new

# create two wallet object
bob = CKB::Wallet.from_hex(api, "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3")
alice = CKB::Wallet.from_hex(api, "0x76e853efa8245389e33f6fe49dcbd359eb56be2f6c3594e12521d2a806d32156")

# bob send 1000 bytes to alice
tx_hash = bob.send_capacity(alice.address, 1000 * 10**8)

# loop up the transaction by tx_hash
api.get_transaction(tx_hash)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG](CHANGELOG.md) for more information.
