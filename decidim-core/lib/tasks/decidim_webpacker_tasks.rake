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
      # PostCSS configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/postcss.config.js", "postcss.config.js"
      # Webpacker configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/webpacker.yml", "config/webpacker.yml"
      # Webpack JS config files
      copy_folder_to_application "decidim-core/lib/decidim/webpacker/webpack", "config"
      # Modify the webpack binstubs
      add_binstub_load_path "bin/webpack"
      add_binstub_load_path "bin/webpack-dev-server"

      # Install JS dependencies
      install_decidim_npm

      # Remove the webpacker dependencies as they come through Decidim dependencies.
      # This ensures we can control their versions from Decidim dependencies to avoid version conflicts.
      webpacker_packages = %w(
        @rails/actioncable
        @rails/activestorage
        @rails/ujs
        @rails/webpacker
        turbolinks
        webpack
        webpack-cli
        @webpack-cli/serve
        webpack-dev-server
      )
      system! "npm uninstall #{webpacker_packages.join(" ")}"
    end

    desc "Upgrade Decidim dependencies in Rails instance application"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      # Update JS dependencies
      install_decidim_npm
    end

    def install_decidim_npm
      system! "npm i #{decidim_npm_package}"
    end

    def decidim_path
      @decidim_path ||= Pathname.new(decidim_gemspec.full_gem_path) if Gem.loaded_specs.has_key?("decidim")
    end

    def decidim_gemspec
      @decidim_gemspec ||= Gem.loaded_specs["decidim"]
    end

    def decidim_npm_package
      case decidim_gemspec.source
      when Bundler::Source::Path
        gem_path = decidim_gemspec.source.path
        gem_path = Pathname.new(ENV["BUNDLE_GEMFILE"]).dirname.join(gem_path) if gem_path.relative?

        # The packages folder needs to be copied to the application folder
        # because the linked dependencies are not installed when packages
        # are installed using file references outside the application root
        # where the `package.json` is located at. For more information, see:
        # https://github.com/npm/cli/issues/2339
        FileUtils.cp_r("#{gem_path}/packages", rails_app_path)
        FileUtils.rm_rf("#{rails_app_path}/packages/all")
        FileUtils.cp_r("#{gem_path}/packages_dev/all_local", rails_app_path.join("packages"))
        FileUtils.mv(rails_app_path.join("packages/all_local"), rails_app_path.join("packages/all"))

        "./packages/all"
      when Bundler::Source::Rubygems
        if decidim_gemspec.version.to_s =~ /\.dev$/
          # With the .dev version the package does not exist at NPM yet.
          "https://gitpkg.now.sh/mainio/decidim/packages_dev/all_git?feature/split-npm-packages"
        else
          "@decidim/all@~#{decidim_gemspec.version}"
        end
      when Bundler::Source::Git
        github_repo =
          decidim_gemspec.source.uri[%r{github\.com/([^/]*/[^.]*)}, 1] ||
          "decidim/decidim"
        branch = decidim_gemspec.source.branch

        "https://gitpkg.now.sh/#{github_repo}/packages_dev/all_git?#{branch}"
      end
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
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

    def add_binstub_load_path(binstub_path)
      file = rails_app_path.join(binstub_path)
      lines = File.readlines(file)

      # Skip if the load path is already added
      return if lines.grep(
        %r{^\$LOAD_PATH.unshift "#\{Gem.loaded_specs\["decidim-core"\].full_gem_path\}/lib/gem_overrides"$}
      ).size.positive?

      contents = ""
      lines.each do |line|
        contents += line
        next unless line =~ %r{^require "bundler/setup"$}

        contents += "\n"
        contents += "# Add the Decidim override load path to override webpacker functionality\n"
        contents += "$LOAD_PATH.unshift \"\#{Gem.loaded_specs[\"decidim-core\"].full_gem_path}/lib/gem_overrides\"\n"
      end

      File.write(file, contents)
    end

    def system!(*args)
      system(*args) || abort("\n== Command #{args} failed ==")
    end
  end
end

# Override the Webpacker instance for the rake tasks to correctly assign the
# configuration file path. This is needed e.g. when `rails assets:precompile` is
# being run. Otherwise webpacker might not recognize if the assets need to be
# compiled again (i.e. if the asset hash has been changed).
if (config_path = Decidim::Webpacker.configuration.configuration_file)
  Webpacker.instance = Webpacker::Instance.new(
    config_path: Pathname.new(config_path)
  )
end
