# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "decidim/gem_manager"
require "decidim/release_manager"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Runs all tests in all Decidim engines"
task test_all: [:test_main, :test_subgems]

desc "Runs all tests in decidim subgems"
task test_subgems: :test_app do
  Decidim::GemManager.run_all("rake", include_root: false)
end

desc "Runs all tests in the main decidim gem"
task :test_main do
  Decidim::GemManager.new(__dir__).run("rake")
end

desc "Update version in all gems to the one set in the `.decidim-version` file"
task :update_versions do
  Decidim::GemManager.replace_versions
end

Decidim::GemManager.all_dirs(include_root: false) do |dir|
  manager = Decidim::GemManager.new(dir)
  name = manager.short_name

  desc "Runs tests on #{name}"
  task "test_#{name}" do
    manager.run("rake")
  end
end

desc "Runs tests for a random participatory space"
task :test_participatory_space do
  Decidim::GemManager.test_participatory_space
end

desc "Runs tests for a random component"
task :test_component do
  Decidim::GemManager.test_component
end

desc "Installs all local gem versions globally"
task :install_all do
  Decidim::GemManager.install_all
end

desc "Uninstalls all local gem versions"
task :uninstall_all do
  Decidim::GemManager.uninstall_all
end

desc "Pushes a new build for each gem and package."
task release_all: [:ensure_git_remote, :fetch_git_tags, :update_versions, :fetch_git_tags, :check_uncommitted_changes, :check_locale_completeness] do
  commands = {}
  Decidim::GemManager.all_dirs { |dir| commands[dir] = "rake release[#{Decidim::ReleaseManager.git_remote}]" }
  Decidim::GemManager.package_dirs { |dir| commands[dir] = "npm publish --access public" }

  commands.each do |dir, command|
    status = Decidim::GemManager.run_at(dir, command)

    break if !status && Decidim::GemManager.fail_fast?
  end
end

task :ensure_git_remote do
  unless Decidim::ReleaseManager.git_remote_set?
    puts "ABORTING RELEASE"
    puts ""
    abort "Please set 'decidim/decidim' as one of your remotes to make a release."
  end
end

desc "Fetches the git tags from the correct remote so that they are up to date before the release."
task :fetch_git_tags do
  system("git fetch #{Decidim::ReleaseManager.git_remote} --tags --force")
end

desc "Makes sure there are no uncommitted changes."
task :check_uncommitted_changes do
  unless system("git diff --exit-code --quiet")
    puts "There are uncommitted changes, run `git diff` to see them."
    abort "Please commit your changes before release!"
  end
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  unless system({ "ENFORCED_LOCALES" => "en,ca,es", "SKIP_NORMALIZATION" => "true" }, "rspec spec/i18n_spec.rb")
    puts "The officially supported locales have problems in them."
    abort "Please correct these problems by following the instructions from the above outputs before release!"
  end
end

load "decidim-dev/lib/tasks/generators.rake"
load "lib/tasks/common_passwords_tasks.rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"

desc "Bundle all Gemfiles"
task :bundle do
  [".", "decidim-generators"].each do |dir|
    Bundler.with_original_env do
      puts "Updating #{dir}...\n"
      system!("bundle install", dir)
    end
  end
end

def root_folder
  @root_folder ||= Pathname.new(__dir__)
end

def system!(command, path)
  system("cd #{path} && #{command}") || abort("\n== Command #{command} failed ==")
end
