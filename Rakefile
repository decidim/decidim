# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "generators/decidim/app_generator"
require "generators/decidim/docker_generator"

DECIDIM_GEMS = %w(core system admin api participatory_processes assemblies pages meetings proposals comments accountability budgets surveys verifications dev).freeze

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Runs all tests in all Decidim engines"
task :test_all do
  RakeUtils.run_all "rake", except: ["dev"]
end

desc "Update version in all gems to the one set in the `.decidim-version` file"
task :update_versions do
  RakeUtils.replace_file(
    "#{__dir__}/package.json",
    /^  "version": "[^"]*"/,
    "  \"version\": \"#{RakeUtils.gsub(/\.pre/, "-pre")}\""
  )

  DECIDIM_GEMS.each do |name|
    RakeUtils.replace_file(
      "#{__dir__}/decidim-#{name}/lib/decidim/#{name}/version.rb",
      /def self\.version(\s*)"[^"]*"/,
      "def self.version\\1\"#{RakeUtils.version}\""
    )
  end

  RakeUtils.replace_file(
    "#{__dir__}/lib/decidim/version.rb",
    /def self\.version(\s*)"[^"]*"/,
    "def self.version\\1\"#{RakeUtils.version}\""
  )
end

desc "Installs all gems locally."
task :install_all do
  RakeUtils.run_all "rake install:local", out: File::NULL
end

desc "Uninstalls all gems locally."
task :uninstall_all do
  system("gem uninstall decidim -v #{RakeUtils.version} --executables --force")
  DECIDIM_GEMS.each do |name|
    system("gem uninstall decidim-#{name} -v #{RakeUtils.version} --executables --force")
  end
end

desc "Pushes a new build for each gem."
task release_all: [:update_versions, :check_locale_completeness, :webpack] do
  RakeUtils.run_all "rake release"
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  system({ "ENFORCED_LOCALES" => "en,ca,es" }, "rspec spec/i18n_spec.rb")
end

desc "Generates a dummy app for testing"
task :test_app do
  dummy_app_path = File.expand_path(File.join(Dir.pwd, "spec", "decidim_dummy_app"))

  Dir.chdir(__dir__) do
    sh "rm -fR #{dummy_app_path}", verbose: false
  end

  Decidim::Generators::AppGenerator.start(
    [dummy_app_path, "--path", "../..", "--recreate_db", "--demo"]
  )
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

desc "Generates a development app based on Docker."
task :docker_development_app do
  docker_app_path = __dir__ + "/docker_development_app"

  Decidim::Generators::DockerGenerator.start(
    ["docker_development_app", "--docker_app_path", docker_app_path]
  )
end

desc "Build webpack bundle files"
task :webpack do
  sh "yarn install && yarn build:prod"
end

module RakeUtils
  def self.replace_file(name, regexp, replacement)
    new_content = File.read(name).gsub(regexp, replacement)

    File.open(name, "w") { |f| f.write(new_content) }
  end

  def self.version
    File.read("#{__dir__}/.decidim-version").strip
  end

  def self.run_all(command, out: STDOUT, except: [])
    tested_gems = DECIDIM_GEMS - except

    dirs = [__dir__] + tested_gems.map { |name| "#{__dir__}/decidim-#{name}" }

    dirs.each do |dir|
      Dir.chdir(dir) do
        puts "Running command '#{command}' inside '#{File.basename(dir)}'..."
        status = system(command, out: out)
        abort unless status || ENV["FAIL_FAST"] == "false"
      end
    end
  end
end
