# frozen_string_literal: true

module Decidim
  # This is a helper class in order to publish component and settings changes
  # so that components can react to these changes and send notifications to users.
  class SettingsChange
    # Publishes a change to ActiveSupport::Notifications.
    #
    # component - The Decidim::Component where the changes have been applied.
    # previous_settings - A Hash or a Decidim::SettingsManifest schema with the settings before changing them.
    # current_settings - A Hash or a Decidim::SettingsManifest schema with the current settings.
    def self.publish(component, previous_settings, current_settings)
      ActiveSupport::Notifications.publish(
        "decidim.settings_change.#{component.manifest_name}",
        component_id: component.id,
        previous_settings: previous_settings.to_h.deep_symbolize_keys,
        current_settings: current_settings.to_h.deep_symbolize_keys
      )
    end

    # Creates a subscription to setting changes.
    #
    # scope - The String manifest name of the component so it only receives relevant changes.
    # block - The block to be executed when an event is received.
    def self.subscribe(scope, &block)
      ActiveSupport::Notifications.subscribe(/^decidim\.settings_change\.#{scope}/) do |_event_name, data|
        block.call(data)
      end
    end
  end
end
