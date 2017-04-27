require "generators/decidim/dummy_generator"

namespace :decidim do
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
