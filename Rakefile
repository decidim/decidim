# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require_relative "lib/generators/decidim/app_generator"

DECIDIM_GEMS = %w(core system admin api).freeze

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
task :release_all do
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
