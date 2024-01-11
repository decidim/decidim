# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

load "decidim-maintainers_toolbox/lib/tasks/gem_manager.rake"
load "decidim-dev/lib/tasks/generators.rake"
load "lib/tasks/common_passwords_tasks.rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"

desc "Bundle all Gemfiles"
task :bundle do
  [".", "decidim-generators"].each do |dir|
    Bundler.with_original_env do
      puts "Updating #{dir}...\n"
      system!("bundle install", dir)
    end
  end
end

def root_folder
  @root_folder ||= Pathname.new(__dir__)
end

def system!(command, path)
  system("cd #{path} && #{command}") || abort("\n== Command #{command} failed ==")
end
