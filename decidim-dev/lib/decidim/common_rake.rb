# frozen_string_literal: true
require_relative "../generators/decidim/dummy_generator"

begin
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake common:test_app`"
  puts "Dummy app's rake tasks won't be available."
  puts "Tried to load it from #{dummy_app_path}"
end

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do
    Decidim::Generators::DummyGenerator.start(
      [
        "--engine_path=#{ENV["ENGINE_PATH"]}",
        "--migrate=true",
        "--quiet"
      ]
    )
    FileUtils.cd(ENV["ENGINE_PATH"])

    dummy_app_path = Dir.glob("./spec/*_dummy_app").first
    require File.join(dummy_app_path, "config", "application")
    Rails.application.load_tasks

    Rake.application["assets:precompile"].invoke
  end
end
