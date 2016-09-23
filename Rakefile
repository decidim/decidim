# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"

begin
  require "decidim/testing_support/common_rake"
rescue LoadError
  raise "Could not find decidim/testing_support/common_rake. You need to run this command using Bundler."
end

DECIDIM_GEMS = %w(core system).freeze

RSpec::Core::RakeTask.new(:spec)

task default: :test

desc "Runs all tests in all Decidim engines"
task :test do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh "rake"
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
