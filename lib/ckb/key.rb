# frozen_string_literal: true

case RUBY_PLATFORM
when "java"
  require "ckb/platform/java/key"
else
  require "ckb/platform/ruby/key"
end
