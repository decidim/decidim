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
        # Write the runtime configuration and override the configuration
        @webpacker_config = Decidim::Webpacker.configuration.configuration_file
      end
    end
  end
end
