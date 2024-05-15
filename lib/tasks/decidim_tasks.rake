# frozen_string_literal: true

def ensure_log_goes_to_stdout
  old_logger = Shakapacker.logger
  Shakapacker.logger = ActiveSupport::Logger.new($stdout)
  yield
ensure
  Shakapacker.logger = old_logger
end

namespace :decidim do
  namespace :webpacker do
    desc "Install deps with npm"
    task :npm_install do
      Dir.chdir(File.join(__dir__, "../..")) do
        system "npm install"
      end
    end
  end
end

def npm_install_available?
  rails_major = Rails::VERSION::MAJOR
  rails_minor = Rails::VERSION::MINOR

  rails_major > 5 || (rails_major == 5 && rails_minor >= 1)
end

# Compile packs after we have compiled all other assets during precompilation
skip_webpacker_precompile = %w(no false n f).include?(ENV.fetch("WEBPACKER_PRECOMPILE", nil))

namespace :decidim do
  namespace :assets do
    desc "Remove 'node_modules' folder"
    task rm_node_modules: :environment do
      Dir.chdir(File.join(__dir__, "../..")) do
        puts "Removing node_modules folder"
        system "rm -rf node_modules"
      end
    end
  end
end

unless skip_webpacker_precompile
  if Rake::Task.task_defined?("assets:clean")
    # npm:install was added in Rails 5.1
    Rake::Task["assets:clean"].enhance([]) do
      Rake::Task["decidim:assets:rm_node_modules"].invoke
    end
  else
    Rake::Task.define_task("assets:clean" => "decidim:assets:rm_node_modules")
  end
end
