# frozen_string_literal: true

module Decidim
  module Configuration
    module SocialShareServicesRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a social share service.
        #
        # Returns nothing.
        def register_social_share_service(name, &)
          social_share_services_registry.register(name, &)
        end

        # Public: Stores the registry of social shares services
        def social_share_services_registry
          @social_share_services_registry ||= ManifestRegistry.new(:social_share_services)
        end
      end
    end
  end
end
