# frozen_string_literal: true

module Decidim
  module Webpacker
    class Configuration
      attr_reader :additional_paths, :entrypoints, :stylesheet_imports

      def initialize
        @additional_paths = []
        @entrypoints = {}
        @stylesheet_imports = {}
      end

      def configuration_file
        # Before webpacker is installed, the original configuration file may not
        # be available yet.
        return unless File.exist?(original_configuration_file_path)
        return configuration_file_path if configurations_loaded?

        load_asset_configurations

        # Read the original configuration and append the paths
        config = YAML.load_file(original_configuration_file_path, aliases: true)
        default = config["default"] || {}
        all_additional_paths = default["additional_paths"] || []
        all_additional_paths += additional_paths
        all_stylesheet_imports = default["stylesheet_imports"] || {}
        all_stylesheet_imports.merge!(stylesheet_imports)
        all_entrypoints = default["entrypoints"] || {}
        all_entrypoints.merge!(entrypoints)
        config.each do |environment, env_config|
          config[environment] = env_config.merge(
            "additional_paths" => all_additional_paths,
            "entrypoints" => all_entrypoints,
            "stylesheet_imports" => all_stylesheet_imports,
            "compile" => (ENV.fetch("SHAKAPACKER_RUNTIME_COMPILE", "false") == "true")
          )
        end

        # Write the runtime configuration and override the configuration
        File.write(configuration_file_path, config.to_yaml)

        self.configurations_loaded = true

        configuration_file_path
      end

      private

      attr_writer :configurations_loaded

      def configurations_loaded?
        @configurations_loaded == true
      end

      def app_path
        @app_path ||=
          if defined?(Rails)
            Rails.application.root
          else
            # This is used when Rails is not available from the webpacker binstubs
            File.expand_path(".", Dir.pwd)
          end
      end

      def configuration_file_path
        @configuration_file_path ||= File.join(app_path, "tmp/webpacker_runtime.yml")
      end

      def original_configuration_file_path
        @original_configuration_file_path = File.join(app_path, "config/shakapacker.yml")
      end

      def load_asset_configurations
        # Decidim gem assets
        decidim_gems = Bundler.load.specs.select { |spec| spec.name =~ /^decidim-/ }
        decidim_gems.each do |gem|
          asset_config_path = File.join(gem.full_gem_path, "config/assets.rb")
          next unless File.exist?(asset_config_path)

          load asset_config_path
        end

        # Application assets
        asset_config_path = File.join(app_path, "config/assets.rb")
        load asset_config_path if File.exist?(asset_config_path)
      end
    end
  end
end
