# frozen_string_literal: true

def ensure_log_goes_to_stdout
  old_logger = Webpacker.logger
  Webpacker.logger = ActiveSupport::Logger.new($stdout)
  yield
ensure
  Webpacker.logger = old_logger
end

namespace :decidim do
  namespace :webpacker do
    desc "Install deps with npm"
    task :npm_install do
      Dir.chdir(File.join(__dir__, "../..")) do
        system "npm install"
      end
    end

    desc "Compile JavaScript packs using webpack for production with digests"
    task compile: [:npm_install, :environment] do
      Webpacker.with_node_env("production") do
        ensure_log_goes_to_stdout do
          if Decidim.webpacker.commands.compile
            # Successful compilation!
            puts "SUCCESS"
            Dir.chdir(File.join(__dir__, "../..")) do
              system "cp -r public/* #{Rails.public_path}"
            end
          else
            # Failed compilation
            puts "FAIL"
            exit!
          end
        end
      end
    end
  end
end

def npm_install_available?
  rails_major = Rails::VERSION::MAJOR
  rails_minor = Rails::VERSION::MINOR

  rails_major > 5 || (rails_major == 5 && rails_minor >= 1)
end

def enhance_assets_precompile
  # npm:install was added in Rails 5.1
  deps = npm_install_available? ? [] : ["decidim:webpacker:npm_install"]
  Rake::Task["assets:precompile"].enhance(deps) do
    Rake::Task["decidim:webpacker:compile"].invoke
  end
end

# Compile packs after we've compiled all other assets during precompilation
skip_webpacker_precompile = %w(no false n f).include?(ENV.fetch("WEBPACKER_PRECOMPILE", nil))

unless skip_webpacker_precompile
  if Rake::Task.task_defined?("assets:precompile")
    enhance_assets_precompile
  else
    Rake::Task.define_task("assets:precompile" => "decidim:webpacker:compile")
  end
end

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

def enhance_assets_clean
  # npm:install was added in Rails 5.1
  Rake::Task["assets:clean"].enhance([]) do
    Rake::Task["decidim:assets:rm_node_modules"].invoke
  end
end

unless skip_webpacker_precompile
  if Rake::Task.task_defined?("assets:clean")
    enhance_assets_clean
  else
    Rake::Task.define_task("assets:clean" => "decidim:assets:rm_node_modules")
  end
end
