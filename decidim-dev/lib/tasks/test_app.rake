# frozen_string_literal: true

require "generators/decidim/app_generator"

namespace :decidim do
  desc "Generates a dummy app for testing in external installations"
  task :generate_external_test_app do
    dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

    Decidim::Generators::AppGenerator.start(
      [
        dummy_app_path,
        "--path",
        "../..",
        "--recreate_db",
        "--app_const_base=DummyApplication",
        "--skip_gemfile",
        "--demo"
      ]
    )
  end
end
