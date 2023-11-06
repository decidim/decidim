# frozen_string_literal: true

require "decidim/generators/app_generator"

namespace :decidim do
  def generate_decidim_app(*options)
    app_path = File.expand_path(options.first, Dir.pwd)

    sh "rm -fR #{app_path}", verbose: false

    original_folder = Dir.pwd

    Decidim::Generators::AppGenerator.start(options)

    Dir.chdir(original_folder)
  end

  def base_app_name
    File.basename(Dir.pwd).underscore
  end

  desc "Generates a dummy app for testing in external installations"
  task :generate_external_test_app do
    generate_decidim_app(
      "spec/decidim_dummy_app",
      "--app_name",
      "#{base_app_name}_test_app",
      "--path",
      "../..",
      "--recreate_db",
      "--skip_gemfile",
      "--skip_spring",
      "--demo",
      "--force_ssl",
      "false",
      "--locales",
      "en,ca,es"
    )
  end

  desc "Generates a dummy app for trying out external modules"
  task :generate_external_development_app do
    Bundler.with_original_env do
      generate_decidim_app(
        "development_app",
        "--app_name",
        "#{base_app_name}_development_app",
        "--path",
        "..",
        "--recreate_db",
        "--seed_db",
        "--demo",
        "--profiling",
        "--locales",
        "en,ca,es",
        "--dev_ssl"
      )
    end
  end
end
