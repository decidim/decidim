# frozen_string_literal: true

require "English"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "decidim/gem_manager"

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
task release_all: [:update_versions, :check_locale_completeness] do
  Decidim::GemManager.run_all("rake release")
  Decidim::GemManager.run_packages("npm publish --access public")
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  system({ "ENFORCED_LOCALES" => "en,ca,es", "SKIP_NORMALIZATION" => "true" }, "rspec spec/i18n_spec.rb")
end

load "decidim-dev/lib/tasks/generators.rake"
load "lib/tasks/common_passwords_tasks.rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"

desc "Bundle all Gemfiles"
task :bundle do
  [".", "decidim-generators", "decidim_app-design"].each do |dir|
    Bundler.with_original_env do
      puts "Updating #{dir}...\n"
      system!("bundle install", dir)
    end
  end
end

desc "Synchronize npm packages files on the whole repo"
task :webpack do
  FileUtils.rm_rf(decidim_app_design_path.join("package-lock.json"))
  FileUtils.rm_rf(decidim_app_design_path.join("packages"))
  FileUtils.cp_r(root_folder.join("package.json"), decidim_app_design_path)
  FileUtils.cp_r(root_folder.join("package-lock.json"), decidim_app_design_path)
  FileUtils.cp_r(root_folder.join("packages"), decidim_app_design_path)

  system!("npm install", root_folder)
  system!("npm install", decidim_app_design_path)
end

desc "Lint Markdown files"
task :lint_markdown do
  status = 0
  Dir.glob(root_folder.join("**/*.md")).each do |file|
    next if file.include?("node_modules")
    next if file.include?("decidim_dummy_app")
    next if file.include?("public/decidim-packs")
    next if file.include?("dev/assets/iso-8859-15.md")
    next if file.include?("vendor/bundle")

    system("mdl #{file}")
    status += $CHILD_STATUS.exitstatus
  end

  exit(status)
end

def root_folder
  @root_folder ||= Pathname.new(__dir__)
end

def decidim_app_design_path
  @decidim_app_design_path ||= Pathname.new(root_folder.join("decidim_app-design"))
end

def system!(command, path)
  system("cd #{path} && #{command}") || abort("\n== Command #{command} failed ==")
end
