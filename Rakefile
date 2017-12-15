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
  tested_gems = DECIDIM_GEMS - ["dev"]

  dirs = [__dir__] + tested_gems.map { |name| "#{__dir__}/decidim-#{name}" }

  dirs.each do |dir|
    Dir.chdir(dir) do
      puts "Running #{File.basename(dir)}'s tests..."
      status = system "rake"
      abort unless status || ENV["FAIL_FAST"] == "false"
    end
  end
end

def replace_file(name, regexp, replacement)
  new_content = File.read(name).gsub(regexp, replacement)

  File.open(name, "w") { |f| f.write(new_content) }
end

def version
  File.read("#{__dir__}/.decidim-version").strip
end

desc "Update version in all gems to the one set in the `.decidim-version` file"
task :update_versions do
  replace_file(
    "#{__dir__}/package.json",
    /^  "version": "[^"]*"/,
    "  \"version\": \"#{version.gsub(/\.pre/, "-pre")}\""
  )

  DECIDIM_GEMS.each do |name|
    replace_file(
      "#{__dir__}/decidim-#{name}/lib/decidim/#{name}/version.rb",
      /def self\.version(\s*)"[^"]*"/,
      "def self.version\\1\"#{version}\""
    )
  end

  replace_file(
    "#{__dir__}/lib/decidim/version.rb",
    /def self\.version(\s*)"[^"]*"/,
    "def self.version\\1\"#{version}\""
  )
end

desc "Installs all gems locally."
task :install_all do
  system "rake install:local"
  DECIDIM_GEMS.each do |name|
    Dir.chdir("#{__dir__}/decidim-#{name}") do
      system "rake install:local"
    end
  end
end

desc "Uninstalls all gems locally."
task :uninstall_all do
  system("gem uninstall decidim -v #{version} --executables --force")
  DECIDIM_GEMS.each do |name|
    system("gem uninstall decidim-#{name} -v #{version} --executables --force")
  end
end

desc "Pushes a new build for each gem."
task release_all: [:update_versions, :check_locale_completeness, :webpack] do
  sh "rake release" rescue nil
  DECIDIM_GEMS.each do |name|
    Dir.chdir("#{__dir__}/decidim-#{name}") do
      sh "rake release" rescue nil
    end
  end
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

  Bundler.with_clean_env do
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

  Bundler.with_clean_env do
    Decidim::Generators::AppGenerator.start(
      ["development_app", "--path", "..", "--recreate_db", "--seed_db", "--demo"]
    )
  end
end

desc "Generates a development app based on Docker."
task :docker_development_app do
  docker_app_path = __dir__ + "/docker_development_app"

  Bundler.with_clean_env do
    Decidim::Generators::DockerGenerator.start(
      ["docker_development_app", "--docker_app_path", docker_app_path]
    )
  end
end

desc "Build webpack bundle files"
task :webpack do
  sh "yarn install && yarn build:prod"
end
