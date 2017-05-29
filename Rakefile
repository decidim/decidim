# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require_relative "lib/generators/decidim/app_generator"
require_relative "lib/generators/decidim/docker_generator"

load "decidim-core/lib/tasks/decidim_tasks.rake"
load "decidim-dev/lib/tasks/test_app.rake"

DECIDIM_GEMS = %w(core system admin api pages meetings proposals comments results budgets dev).freeze

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Runs all tests in all Decidim engines"
task test_all: ["decidim:generate_test_app"] do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      puts "Running #{gem_name}'s tests..."
      sh "rake"
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
    Bundler.with_clean_env do
      sh "bundle exec spring stop"
      sh "bundle exec rake db:drop db:create db:migrate db:seed"
      sh "bundle exec rails generate decidim:demo"
    end
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
