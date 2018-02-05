# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "generators/decidim/app_generator"
require "decidim/component_manager"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Runs all tests in all Decidim engines"
task test_all: [:test_main, :test_subgems]

desc "Runs all tests in decidim subgems"
task test_subgems: :test_app do
  Decidim::ComponentManager.run_all("rake", include_root: false)
end

desc "Runs all tests in the main decidim gem"
task :test_main do
  Decidim::ComponentManager.new(__dir__).run("rake")
end

desc "Update version in all gems to the one set in the `.decidim-version` file"
task :update_versions do
  Decidim::ComponentManager.replace_versions
end

desc "Installs all gems locally."
task :install_all do
  Decidim::ComponentManager.run_all(
    "rake install:local",
    out: File::NULL
  )
end

desc "Uninstalls all gems locally."
task :uninstall_all do
  Decidim::ComponentManager.run_all(
    "gem uninstall %name -v %version --executables --force",
    out: File::NULL
  )
end

desc "Pushes a new build for each gem."
task release_all: [:update_versions, :check_locale_completeness, :webpack] do
  Decidim::ComponentManager.run_all("rake release")
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  system({ "ENFORCED_LOCALES" => "en,ca,es", "SKIP_NORMALIZATION" => true }, "rspec spec/i18n_spec.rb")
end

desc "Generates a dummy app for testing"
task :test_app do
  dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

  Dir.chdir(__dir__) do
    sh "rm -fR #{dummy_app_path}", verbose: false

    Decidim::Generators::AppGenerator.start(
      [dummy_app_path, "--path", "../..", "--recreate_db", "--demo"]
    )
  end
end

desc "Generates a development app."
task :development_app do
  Dir.chdir(__dir__) do
    sh "rm -fR development_app", verbose: false
  end

  Decidim::Generators::AppGenerator.start(
    ["development_app", "--path", "..", "--recreate_db", "--seed_db", "--demo"]
  )
end

desc "Build webpack bundle files"
task :webpack do
  sh "yarn install && yarn build:prod"
end
