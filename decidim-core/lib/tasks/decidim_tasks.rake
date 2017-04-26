# frozen_string_literal: true
# desc "Explaining what the task does"
# task :decidim do
#   # Task goes here
# end
require_relative "../../../decidim-dev/lib/generators/decidim/dummy_generator"

namespace :decidim do
  desc "Install migrations from Decidim to the app."
  task upgrade: ["railties:install:migrations"]

  desc "Generates a dummy app for testing"
  task :generate_test_app do
    dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

    Decidim::Generators::DummyGenerator.start(
      [
        "--dummy_app_path=#{dummy_app_path}",
        "--migrate=true",
        "--quiet"
      ]
    )

    sh "cd #{dummy_app_path} && bundle exec rake assets:precompile"
  end
end
