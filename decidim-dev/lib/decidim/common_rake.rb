# frozen_string_literal: true
require_relative "../generators/decidim/dummy_generator"

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

    dummy_app_path = Dir.glob("./spec/*_dummy_app").first
    require File.join(dummy_app_path, "config", "application")
    Rails.application.load_tasks

    Rake.application["assets:precompile"].invoke

    FileUtils.cd(ENV["ENGINE_PATH"])
  end
end
