# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim do
  namespace :webpacker do
    desc "Installs Decidim webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      # Removing bin/yarn makes assets:precompile task to don't execute `yarn install`
      remove_file_from_application "bin/yarn"
      # Babel config
      copy_file_to_application "babel.config.json"
      # PostCSS configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/postcss.config.js", "postcss.config.js"
      # Tailwind configuration
      copy_template_to_application "decidim-core/lib/decidim/webpacker/tailwind.config.js.erb", "tailwind.config.js", tailwind_variables
      # Webpacker configuration
      copy_file_to_application "decidim-core/lib/decidim/webpacker/webpacker.yml", "config/webpacker.yml"
      # Webpack JS config files
      copy_folder_to_application "decidim-core/lib/decidim/webpacker/webpack", "config"

      # Install JS dependencies
      install_decidim_npm

      # Remove the webpacker dependencies as they come through Decidim dependencies.
      # This ensures we can control their versions from Decidim dependencies to avoid version conflicts.
      webpacker_packages = %w(
        @rails/actioncable
        @rails/activestorage
        @rails/ujs
        turbolinks
      )
      system! "npm uninstall #{webpacker_packages.join(" ")}"

      # Modify the webpack binstubs
      add_binstub_load_path "bin/webpack"
      add_binstub_load_path "bin/webpack-dev-server"

      # Add the Browserslist configuration to the project
      add_decidim_browserslist_configuration
    end

    desc "Upgrade Decidim dependencies in Rails instance application"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      # Update JS dependencies
      install_decidim_npm
    end

    def install_decidim_npm
      decidim_npm_packages.each do |type, packages|
        system! "npm i --save-#{type} #{packages.join(" ")}"
      end
    end

    def add_decidim_browserslist_configuration
      package = JSON.parse(File.read(rails_app_path.join("package.json")))
      return if package["browserslist"].is_a?(Array) && package["browserslist"].include?("extends @decidim/browserslist-config")

      package["browserslist"] = ["extends @decidim/browserslist-config"]
      File.write(rails_app_path.join("package.json"), JSON.pretty_generate(package))
    end

    def decidim_npm_packages
      gem_path = unreleased_gem_path

      if gem_path
        package_spec = "./packages/%s"

        # The packages folder needs to be copied to the application folder
        # because the linked dependencies are not installed when packages
        # are installed using file references outside the application root
        # where the `package.json` is located at. For more information, see:
        # https://github.com/npm/cli/issues/2339
        FileUtils.rm_rf(rails_app_path.join("packages"))
        FileUtils.cp_r(gem_path.join("packages"), rails_app_path)
      else
        package_spec = "@decidim/%s@~#{Decidim::GemManager.semver_friendly_version(decidim_gemspec.version.to_s)}"
      end

      local_npm_dependencies.transform_values { |names| names.map { |name| format(package_spec, name) } }
    end

    def unreleased_gem_path
      if decidim_gemspec.source.is_a?(Bundler::Source::Rubygems)
        return if released_version?

        gem_path = Pathname(decidim_gemspec.full_gem_path)
      else
        gem_path = decidim_gemspec.source.path
        gem_path = Pathname(ENV.fetch("BUNDLE_GEMFILE", nil)).dirname.join(gem_path) if gem_path.relative?
      end

      gem_path
    end

    def local_npm_dependencies
      @local_npm_dependencies ||= begin
        package_json = JSON.parse(File.read(decidim_path.join("package.json")))

        {
          prod: local_npm_dependencies_list(package_json["dependencies"]),
          dev: local_npm_dependencies_list(package_json["devDependencies"])
        }.freeze
      end
    end

    def local_npm_dependencies_list(deps)
      return [] unless deps

      deps.values
          .select { |ref| ref.starts_with?("file:packages/") }
          .map { |ref| ref.delete_prefix("file:packages/") }
    end

    def decidim_path
      @decidim_path ||= Pathname.new(decidim_gemspec.full_gem_path) if Gem.loaded_specs.has_key?("decidim")
    end

    def decidim_gemspec
      @decidim_gemspec ||= Gem.loaded_specs["decidim"]
    end

    def released_version?
      decidim_gemspec.version.segments.last != "dev"
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def copy_file_to_application(origin_path, destination_path = origin_path)
      FileUtils.cp(decidim_path.join(origin_path), rails_app_path.join(destination_path))
    end

    # variables contains the variables to be used in the template, it can be an instance of OpenStruct
    def copy_template_to_application(origin_path, destination_path, variables)
      evaluated_template = ERB.new(File.read(decidim_path.join(origin_path))).result(variables.instance_eval { binding })
      File.write(rails_app_path.join(destination_path), evaluated_template)
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

    def system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def tailwind_variables
      # Get the list of Decidim gems installed and adds the current folder ('.')
      content_directories = Dir.glob("#{Gem.loaded_specs["decidim"].full_gem_path}/decidim-*").push(".")

      # The variable expected by tailwind is a Javascript array of strings
      # The directory globbing with the star is done in Ruby because it was causing an infinite loop
      # when processed by Tailwind
      content_directories_as_array_of_strings = content_directories.map { |content_directory| "'#{content_directory}'" }.join(",")

      OpenStruct.new(tailwind_content_directories: content_directories_as_array_of_strings)
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

# Remove the yarn install prerequisity from assets:precompile
Rake::Task["assets:precompile"].prerequisites.delete("webpacker:yarn_install")

# Add gem overrides path to the beginning in order to override rake tasks
# Needed because of a bug in Rails 6.0 (see the overridden task for details)
$LOAD_PATH.unshift "#{Gem.loaded_specs["decidim-core"].full_gem_path}/lib/gem_overrides"
