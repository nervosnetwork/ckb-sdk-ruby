# ckb-sdk-ruby

[![Build Status](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby.svg?branch=develop)](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby)

Ruby SDK for CKB

## Prerequisites

Require Ruby 2.4 and above.

### Ubuntu

```bash
sudo apt install libsecp256k1-dev libsodium-dev
```

This SDK depends on the [bitcoin-secp256k1](https://github.com/cryptape/ruby-bitcoin-secp256k1) gem. If you are using Ubuntu 16.04 or below, you might need to install libsecp256k1(on which bitcoin-secp256k1 depends) manually. Follow [this](https://github.com/cryptape/ruby-bitcoin-secp256k1#prerequisite) to do so.

### macOS

```bash
brew tap nervosnetwork/tap
brew install libsodium libsecp256k1
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckb-sdk-ruby', github: 'nervosnetwork/ckb-sdk-ruby', require: 'ckb'
```

And then execute:

    $ bundle install

If you just want to use it in a console:

```
git clone https://github.com/nervosnetwork/ckb-sdk-ruby.git
cd ckb-sdk-ruby
bundle install
bundle exec bin/console
```

Or download a jar from releases page, which does not require libsecp256k1 and
libsodium but only JRE to run the console:

```
java -jar ckb-console-VERSION.jar
```

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

Provide wallet with a public key

```ruby
api = CKB::API.new

bob = CKB::Wallet.new(api, "0x024a501efd328e062c8675f2365970728c859c592beeefd6be8ead3d901330bc01")
alice = CKB::Wallet.new(api, "0x0257623ec521657a27204c5590384cd59d9267c06d75ab308070be692251b67c57")

bob_key = "0xe79f3207ea4980b7fed79956d5934249ceac4751a4fae01a0f7c4a96884bc4e3"

tx_hash = bob.send_capacity(alice.address, 1000 * 10**8, key: bob_key)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To create a jar using JRuby, run `bundle exec rake jar`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG](CHANGELOG.md) for more information.
