# frozen_string_literal: true

module Decidim
  module Shakapacker
    module Runner
      def self.included(base)
        base.alias_method :original_initialize, :initialize
        base.send :private, :original_initialize

        base.define_method :initialize do |argv, build_config = nil, bundler_override = nil|
          decidim_initialize(argv, build_config, bundler_override)
          original_initialize(argv, build_config, bundler_override)
        end
      end

      private

      def decidim_initialize(_argv, _build_config = nil, _bundler_override = nil)
        # Write runtime configuration for Tailwind
        # This method is called here because in Decidim CSS compilation is done via Webpack.
        # If CSS is decoupled from JS in the future, this call should be removed.
        Decidim::Assets::Tailwind.write_runtime_configuration

        # Write the runtime configuration and override the configuration
        ENV["SHAKAPACKER_CONFIG"] = Decidim::Shakapacker.configuration.configuration_file
      end
    end
  end
end
