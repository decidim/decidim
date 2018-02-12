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
    "gem build %name && mv %name-%version.gem ..",
    include_root: false
  )

  Decidim::ComponentManager.new(__dir__).run(
    "gem build %name && gem install *.gem"
  )
end

desc "Uninstalls all gems locally."
task :uninstall_all do
  Decidim::ComponentManager.run_all(
    "gem uninstall %name -v %version --executables --force"
  )

  Decidim::ComponentManager.new(__dir__).run(
    "rm decidim-*.gem"
  )
end

desc "Pushes a new build for each gem."
task release_all: [:update_versions, :check_locale_completeness, :webpack] do
  Decidim::ComponentManager.run_all("rake release")
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  system({ "ENFORCED_LOCALES" => "en,ca,es", "SKIP_NORMALIZATION" => "true" }, "rspec spec/i18n_spec.rb")
end

load "decidim-dev/lib/tasks/test_app.rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"

desc "Build webpack bundle files"
task :webpack do
  sh "yarn install && yarn build:prod"
end
