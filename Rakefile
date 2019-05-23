# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

if RUBY_PLATFORM == "java"
  require "warbler"
  Warbler::Task.new
end

task default: :spec
