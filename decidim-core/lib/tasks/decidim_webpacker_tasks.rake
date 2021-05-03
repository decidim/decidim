# frozen_string_literal: true

namespace :decidim do
  namespace :webpacker do
    desc "Installs Decidim webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      # Remove yarn.lock (because bin/rails webpacker:install has been executed)
      remove_file_from_application "yarn.lock"
      # Removing bin/yarn makes assets:precompile task to don't execute `yarn install`
      remove_file_from_application "bin/yarn"
      # Babel config
      copy_file_to_application "babel.config.json"
      # Npm packagesj
      copy_file_to_application "package.json"
      copy_file_to_application "package-lock.json"
      # PostCSS configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/postcss.config.js", "postcss.config.js"
      # Webpacker configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/webpacker.yml", "config/webpacker.yml"
      # Webpack JS config files
      copy_folder_to_application "decidim-core/lib/decidim/webpacker/webpack", "config"

      # Replace DECIDIM_PATH by the path to the gem
      gsub_file rails_app_path.join("config/webpack/custom.js"), /DECIDIM_PATH/, decidim_path.to_s
      gsub_file rails_app_path.join("config/webpacker.yml"), /DECIDIM_PATH/, decidim_path.to_s

      # Install JS dependencies
      system! "npm ci"
    end

    def decidim_path
      @decidim_path ||= Pathname.new(Gem.loaded_specs["decidim"].full_gem_path) if Gem.loaded_specs.has_key?("decidim")
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def gsub_file(path, regexp, *args, &block)
      content = File.read(path.to_s).gsub(regexp, *args, &block)
      File.open(path, "wb") { |file| file.write(content) }
    end

    def copy_file_to_application(origin_path, destination_path = origin_path)
      FileUtils.cp(decidim_path.join(origin_path), rails_app_path.join(destination_path))
    end

    def copy_folder_to_application(origin_path, destination_path = origin_path)
      FileUtils.cp_r(decidim_path.join(origin_path), rails_app_path.join(destination_path))
    end

    def remove_file_from_application(path)
      FileUtils.rm(path, force: true)
    end

    def system!(*args)
      system(*args) || abort("\n== Command #{args} failed ==")
    end
  end
end
