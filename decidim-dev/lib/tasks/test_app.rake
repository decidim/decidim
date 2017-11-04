# frozen_string_literal: true

require "generators/decidim/dummy_generator"

namespace :decidim do
  desc "Generates a dummy app for testing in external installations"
  task :generate_external_test_app do
    dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

    Decidim::Generators::DummyGenerator.start(
      [
        "--dummy_app_path=#{dummy_app_path}",
        "--skip_gemfile"
      ]
    )
  end
end
