# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  # The i18n_spec part needs to go first or it won't be include. It seems like a
  # bug in RSpec to me... https://github.com/rspec/rspec-core/issues/2418
  t.rspec_opts = "--pattern #{__dir__}/test/i18n_spec.rb,**/*_spec.rb"
end
task default: [:spec]
