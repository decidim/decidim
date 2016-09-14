require "bundler/gem_tasks"
require "rspec/core/rake_task"

begin
  require 'decidim/testing_support/common_rake'
rescue LoadError
  raise "Could not find decidim/testing_support/common_rake. You need to run this command using Bundler."
end

DECIDIM_GEMS = %w(core).freeze

RSpec::Core::RakeTask.new(:spec)

task :default => :test

desc "Runs all tests in all Decidim engines"
task test: :test_app do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh 'rspec'
    end
  end
end

desc "Generates a dummy app for testing for every Decidim engine"
task :test_app do
  DECIDIM_GEMS.each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/decidim-#{gem_name}") do
      sh 'rake test_app'
    end
  end
end
