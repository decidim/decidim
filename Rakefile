# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "generators/decidim/app_generator"
require "generators/decidim/docker_generator"
require "decidim/dev"

load "decidim-dev/lib/tasks/test_app.rake"

DECIDIM_GEMS = %w(core system admin api participatory_processes assemblies pages meetings proposals comments results budgets surveys dev).freeze

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

desc "Pushes a new build for each gem."
task release_all: [:check_locale_completeness, :webpack] do
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
      ["development_app", "--path", "..", "--recreate_db", "--seed_db"]
    )

    Dir.chdir("#{__dir__}/development_app") do
      sh "bundle exec spring stop", verbose: false
      sh "bundle exec rails generate decidim:demo", verbose: false
    end
  end
end

desc "Generates a development app based on Docker."
task :docker_development_app do
  Dir.chdir(__dir__) do
    sh "rm -fR docker_development_app"
  end

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
