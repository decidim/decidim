# frozen_string_literal: true
require_relative "../generators/decidim/dummy_generator"


begin
  require "./spec/#{ENV["ENGINE_NAME"]}_dummy_app/config/application"
  Rails.application.load_tasks
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
  puts "Dummy app's rake tasks won't be available."
  puts "Tried to load it from #{dummy_app_path}"
end


desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do |_t, _args|
    Decidim::Generators::DummyGenerator.start [
      "--engine_path=#{ENV["ENGINE_PATH"]}",
      "--migrate=true",
      "--quiet"
    ]
    FileUtils.cd(ENV["ENGINE_PATH"])
  end
end
