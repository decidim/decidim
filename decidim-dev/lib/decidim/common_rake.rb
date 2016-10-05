# frozen_string_literal: true
require_relative "../generators/decidim/dummy_generator"

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do |_t, _args|
    Decidim::Generators::DummyGenerator.start [
      "--engine_path=#{ENV["ENGINE_PATH"]}",
      "--migrate=true",
      "--quiet"
    ]
  end
end
