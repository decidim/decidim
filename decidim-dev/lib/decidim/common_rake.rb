# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require_relative "../generators/decidim/dummy_generator"

engine_path = Dir.pwd
engine_name = engine_path.split("/").last
dummy_app_path = File.expand_path(File.join(engine_path, "spec", "#{engine_name}_dummy_app"))

desc "Generates a dummy app for testing"
task :generate_test_app do
  Decidim::Generators::DummyGenerator.start(
    [
      "--engine_path=#{engine_path}",
      "--migrate=true",
      "--quiet"
    ]
  )

  require File.join(dummy_app_path, "config", "application")
  Rails.application.load_tasks
  Rake.application["assets:precompile"].invoke

  FileUtils.cd(engine_path)
end

RSpec::Core::RakeTask.new(:spec)
task default: [:generate_test_app, :spec]
