# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "generators/decidim/app_generator"
require "generators/decidim/docker_generator"
require "decidim/dev"

load "decidim-dev/lib/tasks/test_app.rake"

DECIDIM_GEMS = %w(core system admin api participatory_processes assemblies pages meetings proposals comments accountability budgets surveys dev).freeze

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

desc "Update version in all gems to the one set in the `.decidim-version` file"
task :update_versions do
  version = File.read("#{__dir__}/.decidim-version").strip

  replace_file(
    "#{__dir__}/package.json",
    /^  "version": "[^"]*"/,
    "  \"version\": \"#{version}\""
  )

  replace_file(
    "#{__dir__}/package-lock.json",
    /^  "version": "[^"]*"/,
    "  \"version\": \"#{version}\""
  )

  DECIDIM_GEMS.each do |gem_name|
    replace_file(
      "#{__dir__}/decidim-#{gem_name}/lib/decidim/#{gem_name}/version.rb",
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
  sh "rake install", verbose: false
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{__dir__}/decidim-#{gem_name}") do
      sh "rake install", verbose: false
    end
  end
end

desc "Pushes a new build for each gem."
task release_all: [:update_versions, :check_locale_completeness, :webpack] do
  sh "rake release"
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{__dir__}/decidim-#{gem_name}") do
      sh "rake release"
    end
  end
end

desc "Makes sure all official locales are complete and clean."
task :check_locale_completeness do
  system({ "ENFORCED_LOCALES" => "en,ca,es" }, "rspec spec/i18n_spec.rb")
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
  path = __dir__ + "/docker_development_app"

  Bundler.with_clean_env do
    Decidim::Generators::DockerGenerator.start(
      ["docker_development_app", "--path", path]
    )
  end
end

desc "Build webpack bundle files"
task webpack: ["npm:install"] do
  sh "npm run build:prod"
end

desc "Install npm dependencies"
task "npm:install" do
  sh "npm i"
end
