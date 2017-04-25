# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require_relative "lib/generators/decidim/app_generator"
require_relative "lib/generators/decidim/docker_generator"
require_relative "./decidim-dev/lib/generators/decidim/dummy_generator"

DECIDIM_GEMS = %w(core system admin api pages meetings proposals comments results budgets dev).freeze

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Runs all tests in all Decidim engines"
task :test_all do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh "rake"
    end
  end
end

desc "Generates test apps for all the engines"
task :generate_all do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh "rake generate_test_app"
    end
  end
end

desc "Pushes a new build for each gem."
task release_all: [:webpack] do
  sh "rake release"
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh "rake release"
    end
  end
end

desc "Generates a development app."
task :development_app do
  Dir.chdir(File.dirname(__FILE__)) do
    sh "rm -fR development_app"
  end

  Decidim::Generators::AppGenerator.start(
    ["development_app", "--path", ".."]
  )

  Dir.chdir("#{File.dirname(__FILE__)}/development_app") do
    sh "bundle exec spring stop"
    sh "bundle exec rake db:drop db:create db:migrate db:seed"
    sh "bundle exec rails generate decidim:demo"
  end
end

desc "Generates a development app based on Docker."
task :docker_development_app do
  Dir.chdir(File.dirname(__FILE__)) do
    sh "rm -fR docker_development_app"
  end

  path = File.dirname(__FILE__) + "/docker_development_app"

  Decidim::Generators::DockerGenerator.start(
    ["docker_development_app", "--path", path]
  )
end

desc "Build webpack bundle files"
task webpack: ["yarn:install"] do
  sh "yarn build:prod"
end

desc "Install yarn dependencies"
task "yarn:install" do
  sh "yarn"
end

engine_path = Dir.pwd
dummy_app_path = File.expand_path(File.join(engine_path, "spec", "decidim_dummy_app"))

desc "Generates a dummy app for testing"
task :generate_test_app do
  unless Dir.exists? dummy_app_path
    Decidim::Generators::DummyGenerator.start(
      [
        "--engine_path=#{engine_path}",
        "--migrate=true",
        "--quiet"
      ]
    )

    require File.join(dummy_app_path, "config", "application")
    Rails.application.load_tasks
    Rake.application["assets:precompile"].invoke

    FileUtils.cd(engine_path)
  end
end
