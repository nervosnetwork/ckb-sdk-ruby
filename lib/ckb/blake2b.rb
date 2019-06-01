# frozen_string_literal: true

case RUBY_PLATFORM
when "java"
  require "ckb/platform/java/blake2b"
else
  require "ckb/platform/ruby/blake2b"
end
