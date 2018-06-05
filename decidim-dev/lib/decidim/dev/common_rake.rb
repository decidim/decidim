# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "decidim/dev"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format doc" if ENV["CI"]
end
task default: [:spec]

Decidim::Dev.install_tasks
