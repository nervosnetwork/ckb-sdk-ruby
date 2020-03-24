# frozen_string_literal: true
require "singleton"

module CKB
  class Config
    include Singleton
    attr_accessor :lock_handlers, :type_handlers

    def initialize
      @lock_handlers = {
        [CKB::SystemCodeHash::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, CKB::ScriptHashType::TYPE] => CKB::SingleSign
      }
      @type_handlers = {}
    end

    def lock_handler(lock_script)
      lock_handlers[[lock_script.code_hash, lock_script.hash_type]]
    end

    def type_handler(type_script)
      type_handlers[[type_script.code_hash, type_script.hash_type]]
    end
  end
end
