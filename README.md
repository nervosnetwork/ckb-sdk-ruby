# ckb-sdk-ruby

[![Build Status](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby.svg?branch=develop)](https://travis-ci.com/nervosnetwork/ckb-sdk-ruby)

Ruby SDK for CKB

## Prerequisites

Please be noted that the SDK depends on the [bitcoin-secp256k1](https://github.com/cryptape/ruby-bitcoin-secp256k1) gem and the [rbnacl](https://github.com/crypto-rb/rbnacl) gem, which require manual install of secp256k1 and libsodium library. Follow [this](https://github.com/cryptape/ruby-bitcoin-secp256k1#prerequisite) and [this](https://github.com/crypto-rb/rbnacl#installation) to install them locally.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckb-sdk-ruby', github: 'nervosnetwork/ckb-sdk-ruby', require: 'ckb'
```

And then execute:

    $ bundle

## Usage

RPC interface:

```ruby
api = CKB::API.new
# using RPC `get_tip_header`
api.get_tip_header
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Changelog

See [CHANGELOG](CHANGELOG.md) for more information.
