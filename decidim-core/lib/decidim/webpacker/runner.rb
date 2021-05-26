# frozen_string_literal: true

module Decidim
  module Webpacker
    module Runner
      def self.included(base)
        base.alias_method :original_initialize, :initialize
        base.send :private, :original_initialize

        base.define_method :initialize do |argv|
          original_initialize(argv)
          decidim_initialize(argv)
        end
      end

      private

      def decidim_initialize(_argv)
        # Decidim gem assets
        decidim_gems = Bundler.load.specs.select { |spec| spec.name =~ /^decidim-/ }
        decidim_gems.each do |gem|
          asset_config_path = "#{gem.full_gem_path}/config/assets.rb"
          next unless File.exist?(asset_config_path)

          load asset_config_path
        end

        # Application assets
        asset_config_path = File.join(@app_path, "config/assets.rb")
        load asset_config_path if File.exist?(asset_config_path)

        # Read the original configuration and append the paths
        config = YAML.load_file(@webpacker_config)
        default = config["default"] || {}
        additional_paths = default["additional_paths"] || []
        additional_paths += Decidim::Webpacker.configuration.additional_paths
        entrypoints = Decidim::Webpacker.configuration.entrypoints
        config.each do |environment, env_config|
          config[environment] = env_config.merge(
            "additional_paths" => additional_paths,
            "entrypoints" => entrypoints
          )
        end

        # Write the runtime configuration and override the configuration
        @webpacker_config = File.join(@app_path, "tmp/webpacker_runtime.yml")
        File.write(@webpacker_config, config.to_yaml)
      end
    end
  end
end
