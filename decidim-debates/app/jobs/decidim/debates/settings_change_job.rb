# frozen_string_literal: true

module Decidim
  module Debates
    class SettingsChangeJob < ApplicationJob
      def perform(component_id, previous_settings, current_settings)
        return if unchanged?(previous_settings, current_settings)

        component = Decidim::Component.find(component_id)

        if debate_creation_enabled?(previous_settings, current_settings)
          event = "decidim.events.debates.creation_enabled"
          event_class = Decidim::Debates::CreationEnabledEvent
        elsif debate_creation_disabled?(previous_settings, current_settings)
          event = "decidim.events.debates.creation_disabled"
          event_class = Decidim::Debates::CreationDisabledEvent
        end

        return unless event && event_class

        Decidim::EventsManager.publish(
          event:,
          event_class:,
          resource: component,
          followers: component.participatory_space.followers
        )
      end

      private

      def unchanged?(previous_settings, current_settings)
        current_settings[:creation_enabled] == previous_settings[:creation_enabled]
      end

      # rubocop:disable Style/DoubleNegation
      def debate_creation_enabled?(previous_settings, current_settings)
        current_settings[:creation_enabled] == true &&
          !!previous_settings[:creation_enabled] == false
      end

      def debate_creation_disabled?(previous_settings, current_settings)
        !!current_settings[:creation_enabled] == false &&
          previous_settings[:creation_enabled] == true
      end
      # rubocop:enable Style/DoubleNegation
    end
  end
end
