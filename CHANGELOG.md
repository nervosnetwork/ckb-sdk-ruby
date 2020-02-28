# [v0.29.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.28.0...v0.29.0) (2020-02-28)

* change outputs_validator default to nil on `rpc` and `api` module

# [v0.28.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.27.1...v0.28.0) (2020-02-07)

Bump version to v0.28.0


# [v0.27.1](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.26.1...v0.27.1) (2020-02-04)


### Features

* update send_transaction rpc ([295869f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/295869f))


### BREAKING CHANGES

* add outputs_validator to send_transaction rpc



All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

# [v0.26.1](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.26.0...v0.26.1) (2020-01-02)


### Features

* add `get_capacity_by_lock_hash` RPC ([9de8da2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9de8da23ec14f83178b72efa1a831973cad73cf8))


# [v0.26.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.25.2...v0.26.0) (2019-12-16)


### Features

* update `get_cells_by_lock_hash` and `get_live_cells_by_lock` returns ([65f76c4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/65f76c48ce91752442aa68dc57af0a9a7061ac9e))


# [v0.25.2](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.25.1...v0.25.2) (2019-11-17)


### Bug Fixes

* add options to wallet.from_hex ([ac2b658](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ac2b658cada45dcbec0b041ea2347e0b072f43d1))


# [v0.25.1](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.25.0...v0.25.1) (2019-11-17)


### Bug Fixes

* add default value for reduce in get_unspent_cells ([e14901b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e14901bbbde21c17d75546669ab3081e2850af70))


# [v0.25.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.24.0...v0.25.0) (2019-11-16)


### Bug Fixes

* InsufficientCellCapacity when collect cells ([4c8fdb4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4c8fdb498898f34b7180564609032aa6bb935fd5))
* remove multi sign secp group out point ([4b65500](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4b65500d018f0c69b7cd073c7b45b753d7d976fb))


### Features

* add address parser ([3d3c4f3](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3d3c4f3974dd051f8eea4aee8ec343169022256e))
* add system code hash module ([008ab21](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/008ab2114417a1afdd88e1e98298a43bd69ee0d5))
* check hash type ([3c9eed8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3c9eed84aabb3b26170aaaa746a231b2cb49e322))
* Fix multi sign wallet ([c75e6fe](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c75e6febdc142a2e84f74b8ed17b3f8840b93b86))


### BREAKING CHANGES

* remove min_capacity in gather_inputs


# [v0.24.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.23.1...v0.24.0) (2019-11-02)


### Bug Fixes

* Use correct deposit out point to calculate withdraws ([5f39400](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/5f39400fc799ccd5d167497e4f725d776ca89990))
* Witness processing ([7a20ee1](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/7a20ee18bd2f0dea31fe79fa93c9fc2d80e5fe30))


### Features

* adapt new sign logic ([477b5dd](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/477b5ddd1cd994d8f5248d5d03e1b9935ad14234))
* Adapt to latest 2-phase Nervos DAO ([f30f244](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/f30f244432d535eefc3aa46d1ec4a784a2709abf))
* add `estimate_fee_rate` RPC ([13a6e04](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/13a6e04f7d611aee8d3fb523a8ac5bb386ddb674))
* Add basic multi sign wallet ([684dd8c](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/684dd8c69d573187487e74e5284648a95033a3b0))
* Add blake160 hash to multi-sign pubkeys ([5367be2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/5367be26f216be92793b38a0ed3c690d5d66745c))
* add bytes opt and witness args serializers ([a1f8dbe](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a1f8dbeca5c8d8a76b5fee9ff123a1e289f42b2c))
* support send capacity to multisig address ([a730fae](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a730fae44a064a042c7dcfd8c85af136542b4bdf))
* update expected code hash ([6087c22](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/6087c2256ea263029f8cbb560b58dabef1adecd7))


# [v0.23.1](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.23.0...v0.23.1) (2019-10-21)


### Bug Fixes

* add fee to dao ([c5a8ee4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c5a8ee4b2e7b0e501bdde60550668c9dc7867199))


# [v0.23.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.22.0...v0.23.0) (2019-10-19)


### Bug Fixes

* comment symbol ([3b3682b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3b3682bb5ad2ba40f28443591994dcf650773a8f))


### Features

* Add MockTransactionDumper ([5a48827](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/5a4882722c83584122535872ea8ed8dbcdc30f22))
* calculate transaction size ([df1f304](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/df1f304e0f0387acec36aad8399c9ca43d4f96c6))


# [v0.22.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.21.0...v0.22.0) (2019-10-05)


### Features

* add `CellCollector` ([c5fd7f8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c5fd7f8))
* add CellOutputWithOutPoint type and add block_hash ([2ab7217](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2ab7217))
* add sign_input for transaction ([27498fa](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/27498fa))
* add submit_block api ([60443f7](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/60443f7))
* add template related types ([46bec62](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/46bec62))
* change args type to string ([ca1a6b8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ca1a6b8))
* change witnesses to String[] ([f946c9d](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/f946c9d))
* get_block_template api ([942d525](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/942d525))
* get_block_template rpc ([ecfe65e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ecfe65e))
* remove uncles_count from block header ([5508b9e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/5508b9e))
* remove witnesses_root from block header ([ca6417f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ca6417f))
* replace difficulty with compact_target ([a88ef6b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a88ef6b))
* submit_block rpc ([2a10a7a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2a10a7a))
* update args serializer ([c59691a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c59691a))
* update expected code_hash and type_hash ([78f3f59](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/78f3f59))
* update full payload address generator ([c985667](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c985667))
* update NervosDAO lock period to 180 epochs ([8ecb8f2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8ecb8f2))
* update witnesses type ([3838fd8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3838fd8))


# [v0.21.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.20.0...v0.21.0) (2019-09-21)


### Bug Fixes

* return hex string format type ([c3c9af7](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c3c9af7))


### Features

* add cell data ([4e7d661](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4e7d661))
* add cell info ([8b47dcb](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8b47dcb))
* add chain_root to block header ([af3f10f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/af3f10f))
* add errors on Address ([66dc62a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/66dc62a))
* add to_raw_transaction_h method ([9e14366](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9e14366))
* add with_data to get_live_cell ([40e85d3](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/40e85d3))
* add with_hash to transaction to_h ([55abb63](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/55abb63))
* change all number to integer and convert to hex string in RPC interface ([a1f0495](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a1f0495))
* change to class method ([4a7ea7e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4a7ea7e))
* implement new type addresses ([d2b7a98](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d2b7a98))


### BREAKING CHANGES

* All number type changed to integer and will convert to hex string in RPC interface


# [v0.20.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.19.0...v0.20.0) (2019-09-07)


### Bug Fixes

* test ([8ac5926](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8ac5926))
* type script serialization ([b72fe3e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/b72fe3e))
* wrong dep_type value ([51d5f95](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/51d5f95))


### Features

* add composite data serializers ([7783444](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/7783444))
* add compute_hash to transaction ([7ae9c92](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/7ae9c92))
* add compute_transaction_hash method ([d69ebf2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d69ebf2))
* add transaction serialization related serializers ([4488008](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4488008))
* serialize script ([155c472](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/155c472))
* update expected code_hash and type_hash ([37f0684](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/37f0684))
* update expected code_hash and type_hash ([313ee86](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/313ee86))
* use struct replace some table ([c5e1f17](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c5e1f17))


# [v0.19.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.18.0...v0.19.0) (2019-08-27)


### Bug Fixes

* dao ([06f2b16](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/06f2b16))
* fix expected_code_hash and add expected_type_hash ([bd5af2f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/bd5af2f))
* update dao code_hash and out_point ([3b20b9d](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3b20b9d))
* using data to calculate capacity ([9a9751a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9a9751a))


### Features

* add CellDep type ([56c1412](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/56c1412))
* add compute_script_hash rpc ([573c07b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/573c07b))
* add outputs_data to dao ([6ade1f8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/6ade1f8))
* extract data ([01b02aa](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/01b02aa))
* set hash_type manually ([07f34f9](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/07f34f9))
* skip data and type in wallet when get unspent cells ([733e692](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/733e692))
* update calculate min capacity ([1945c43](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/1945c43))
* update OutPoint structure ([8698259](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8698259))
* use dep group ([32429fa](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/32429fa))
* use type hash ([5fa7967](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/5fa7967))


# [v0.18.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.17.0...v0.18.0) (2019-08-10)


### Bug Fixes

* dao as a script ([cbb83ea](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/cbb83ea))


# [v0.17.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.16.0...v0.17.0) (2019-07-27)


### Features

* add block reward type ([32ee77e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/32ee77e))
* add dao to block header ([1340fb9](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/1340fb9))
* Add hash type per CKB changes ([aa88f93](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/aa88f93))
* add new apis ([75d7a81](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/75d7a81))
* add new net RPCs: `set_ban` & `get_banned_addresses` ([3fc160b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3fc160b))
* Update address generator as per recent RFC 21 change ([2ccf2f4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2ccf2f4))
* using attr_accessor ([8d835e3](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8d835e3))


### BREAKING CHANGES

* A public key will derive different address from previous implementation.
As the code hash index has been changed from 4 bytes to 1 byte, the first several fixed
characters will become ckt1qyq from ckb1q9gry5zg and be shorter.


# [v0.16.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.15.0...v0.16.0) (2019-07-13)


### Bug Fixes

* charge => change ([7c85390](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/7c85390))

### Features

* support `fee` in `send_capacity` ([a1d48cd](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a1d48cd))

# [v0.15.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.14.0...v0.15.0) (2019-06-29)


### Bug Fixes

* `get_unspent_cells` should return cells of genesis block ([a9dee82](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a9dee82))


### Features

* accept pubkey in `Wallet.new` ([c175710](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c175710))
* add alert message and update chain info ([d9580e6](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d9580e6))
* add indexer RPCs ([0fcb2d2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/0fcb2d2))
* add indexer RPCs to API ([a868af0](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a868af0))
* add indexer types ([fedf9dc](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/fedf9dc))
* add sign_recoverable and use in default ([e96a680](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e96a680))
* remove jruby support ([f42e369](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/f42e369))
* use recoverable signature ([bb2838c](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/bb2838c))


### BREAKING CHANGES

* remove jruby support


# [v0.14.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.13.0...v0.14.0) (2019-06-15)


### Bug Fixes

* one more test fix ([c675b3e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c675b3e))
* test ([4be8ac8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4be8ac8))
* unit test ([a16ab01](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a16ab01))


### Features

* add `self.parse` method to `Address` ([ca8b4bf](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ca8b4bf))
* add hexdigest to blake2b ([d1fdd3f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d1fdd3f))
* Remove Input#block_number which was not used ([4716172](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4716172))
* update SDK based on new verification model ([4cad0ab](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4cad0ab))
* update system code hash ([6d18d5a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/6d18d5a))


# [v0.13.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.12.2...v0.13.0) (2019-06-01)


### Bug Fixes

* add a guard in `send_capacity` to check whether the capacity is enough to hold the output ([8fc7dae](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8fc7dae))


### Features

* add calculate_capacity for output and script ([841cfc2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/841cfc2))
* add executable ckb-console ([80a915f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/80a915f))
* add two attrs to `TxPoolInfo` ([e737235](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e737235))
* remove C extension dependencies for JRuby ([f015374](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/f015374))
* support jruby and warbler ([c22486a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c22486a))


# [v0.12.2](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.12.1...v0.12.2) (2019-05-21)


### Bug Fixes

* update ffi version ([b0db2c7](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/b0db2c7))


### Features

* allows sending capacity with data ([9ffd2f3](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9ffd2f3))
* Take pubkey hash(blake160) instead of pubkey as Address input ([3fe2fab](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3fe2fab))


### BREAKING CHANGES

* Address initialize requires blake160 (pubkey hash). Use Address.from_pubkey(pubkey)
to create address for pubkey.


# [v0.12.1](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.12.0...v0.12.1) (2019-05-18)


### Bug Fixes

* fix for gather_inputs when diff = 0 ([e690a71](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e690a71))


### Features

* persistent http client ([041eb60](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/041eb60))


# [v0.12.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.11.0...v0.12.0) (2019-05-18)


### Bug Fixes

* fix cell exception ([df5a81d](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/df5a81d))
* fix dao generation bug ([91f40ee](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/91f40ee))
* fix types ([aeb03fb](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/aeb03fb))
* fix witnesses_root ([fb26eac](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/fb26eac))
* remove check self in from_h ([8758713](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/8758713))
* return if hash.nil? in from_h ([28b61cb](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/28b61cb))
* script test ([2838ed8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2838ed8))


### Code Refactoring

* rename to system_script_code_hash ([036c6bd](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/036c6bd))


### Features

* add `dry_run_transaction` RPC ([4501a69](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4501a69))
* add `get_epoch_by_number` RPC ([51eb43f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/51eb43f))
* add `get_peers` & `tx_pool_info` RPCs ([77ec29c](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/77ec29c))
* add `TxPoolInfo` type ([0f257a4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/0f257a4))
* add data setter in `Types::Witness` ([4774ead](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4774ead))
* add epoch type and add `get_current_epoch` RPC ([035d43e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/035d43e))
* add peer and address_info types ([933da45](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/933da45))
* add state RPCs ([2ec5580](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2ec5580))
* add types ([1347073](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/1347073))
* follow RPCs to set number to string ([4891865](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4891865))
* Generalize OutPoint struct to reference headers ([253f96b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/253f96b))
* keep der signature ([e54e5d2](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e54e5d2))
* NervosDAO integration ([0f6ec28](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/0f6ec28))
* remove unneeded blake2b hash ([fdb1a42](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/fdb1a42))
* Test transaction sign ([ab45e04](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ab45e04))
* update SDK per lock script changes ([29ad6ae](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/29ad6ae))
* update system script cell index to 1 ([6c0759f](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/6c0759f))
* use fixed code_hash and out_point in testnet mode ([adb47f4](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/adb47f4))
* using genesis block first transaction second output as system script ([518a124](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/518a124))
* using real tx_hash after sign ([373e38a](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/373e38a))


### BREAKING CHANGES

* `system_script_cell_hash` => `system_script_code_hash`
* trace RPCs are deleted
* `api.tx_pool_info` returns `TxPoolInfo` instead of `Hash`
* `local_node_info` and `get_peers` return types instead of Hash
* `OutPoint` structure changed


# [v0.11.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.10.0...v0.11.0) (2019-05-14)


### Features

* add RPC `get_block_by_number` ([c410ec3](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/c410ec3))


### BREAKING CHANGES

* rename variables ([a59158b](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a59158b))
  * rename OutPoint `hash` to `tx_hash`
  * rename Script `binary_hash` to `code_hash`
  * rename Input `valid_since` to `since`
  * rename Block `commit_transactions` to `transactions`
* update test of `get_transaction` for structure changes ([3b8c637](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/3b8c637))
* use shannon as capacity unit ([9a013ae](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9a013ae))


# [v0.10.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.9.0...v0.10.0) (2019-05-06)

### Bug Fixes

* capacity in RPC interface changed to string ([d8d3d05](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d8d3d05))
* remove version from script ([9348185](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/9348185))


### Features

* use 0x-prefix hex string represent block assembler args ([171e08e](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/171e08e))



# [v0.9.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.8.0...v0.9.0) (2019-04-22)

### Bug Fixes

* fix code per CKB's latest changes ([7505edf](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/7505edf))
* fix segwit logic ([460caab](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/460caab))
* Fix tests ([0afc5bc](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/0afc5bc))
* fix the bug in transaction generation ([ca33aa7](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ca33aa7))
* Fix the bug that shared lock gets modified when sending tx ([21092de](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/21092de))
* fix witnesses format ([d87d9d8](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/d87d9d8))
* remove duplicated lock in wallet ([e814920](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/e814920))


### Features

* Address format implementation ([4c543bf](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/4c543bf))
* support segwit ([6959395](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/6959395))
* Upgrade SDK with latest CKB changes ([ae5c1c5](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/ae5c1c5))



# [v0.8.0](https://github.com/nervosnetwork/ckb-sdk-ruby/compare/v0.7.0...v0.8.0) (2019-04-08)

### Bug Fixes

* fix tx rpc tests logic



# [v0.7.0](https://github.com/nervosnetwork/ckb-sdk-ruby/tree/v0.7.0) (2019-03-22)


### Features

* add basic wallet ([2e14b49](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/2e14b49))
* add rpc interface ([a4b1f47](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/a4b1f47))
* init project ([1cb5623](https://github.com/nervosnetwork/ckb-sdk-ruby/commit/1cb5623))
* extract from ([ckb-demo-ruby](https://github.com/nervosnetwork/ckb-demo-ruby))
