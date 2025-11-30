# frozen_string_literal: true

module Decidim
  module Configuration
    module NotificationSettingsRegistry
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # Public: Registers a notification setting.
        #
        # Returns nothing.
        def self.notification_settings(name, &)
          notification_settings_registry.register(name, &)
        end

        # Public: Stores the registry of notifications settings
        def notification_settings_registry
          @notification_settings_registry ||= ManifestRegistry.new(:notification_settings)
        end
      end
    end
  end
end
