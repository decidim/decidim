# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "parallel_tests/tasks"
require "decidim/dev"

RSpec::Core::RakeTask.new(:spec) do |t|
  # This options aren't loaded in CI (we are using parallel_tests gem)
  t.rspec_opts = "--format progress --format RspecJunitFormatter -o ~/rspec/rspec.xml" if ENV["CI"]
end
task default: [:spec]

Decidim::Dev.install_tasks
