# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--pattern **/*_spec.rb,#{__dir__}/test/i18n_spec.rb"
end
task default: [:spec]
