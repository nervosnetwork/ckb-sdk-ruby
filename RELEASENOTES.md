# [v0.101.0](https://github.com/shaojunda/ckb-sdk-ruby/compare/v0.41.0...v0.101.0) (2021-10-25)


### Bug Fixes

* default indexer collector ([1343c5e](https://github.com/shaojunda/ckb-sdk-ruby/commit/1343c5e))
* indexer collector bug ([64be7dd](https://github.com/shaojunda/ckb-sdk-ruby/commit/64be7dd))
* indexer collector bug ([15528e4](https://github.com/shaojunda/ckb-sdk-ruby/commit/15528e4))
* sudt amount ([2e64531](https://github.com/shaojunda/ckb-sdk-ruby/commit/2e64531))
* sudt cell dep duplicate ([1b86b04](https://github.com/shaojunda/ckb-sdk-ruby/commit/1b86b04))
* typo ([b1379b0](https://github.com/shaojunda/ckb-sdk-ruby/commit/b1379b0))


### Code Refactoring

* **hardfork:** rename uncles_hash to extra_hash ([ccd7545](https://github.com/shaojunda/ckb-sdk-ruby/commit/ccd7545))
* remove estimate_fee_rate RPC ([702f4c5](https://github.com/shaojunda/ckb-sdk-ruby/commit/702f4c5))


### Features

* **hardfork:** add a new field "hardfork_features" to get_consensus RPC ([ab2d4ca](https://github.com/shaojunda/ckb-sdk-ruby/commit/ab2d4ca))
* **hardfork:** add extension to block ([4f1461a](https://github.com/shaojunda/ckb-sdk-ruby/commit/4f1461a))
* **hardfork:** add new allowed value 'data1' to hash_type ([fec87fd](https://github.com/shaojunda/ckb-sdk-ruby/commit/fec87fd))
* **hardfork:** support new full payload address format ([80a9f97](https://github.com/shaojunda/ckb-sdk-ruby/commit/80a9f97))


### BREAKING CHANGES

* **hardfork:** The field "uncles_hash" in "header" will be renamed to "extra_hash"
  https://github.com/nervosnetwork/ckb/pull/2776
* remove estimate_fee_rate API and RPC method
