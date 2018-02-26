# frozen_string_literal: true

require "generators/decidim/app_generator"

namespace :decidim do
  desc "Generates a dummy app for testing in external installations"
  task :generate_external_test_app do
    dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

    sh "rm -fR spec/decidim_dummy_app", verbose: false

    original_folder = Dir.pwd

    Decidim::Generators::AppGenerator.start(
      [
        dummy_app_path,
        "--path",
        "../..",
        "--recreate_db",
        "--skip_gemfile",
        "--demo"
      ]
    )

    Dir.chdir(original_folder)
  end

  desc "Generates a dummy app for trying out external modules"
  task :generate_external_development_app do
    dummy_app_path = File.expand_path(File.join(Dir.pwd, "development_app"))

    sh "rm -fR development_app", verbose: false

    original_folder = Dir.pwd

    Decidim::Generators::AppGenerator.start(
      [
        dummy_app_path,
        "--path",
        "..",
        "--recreate_db",
        "--seed_db",
        "--demo"
      ]
    )

    Dir.chdir(original_folder)
  end
end
