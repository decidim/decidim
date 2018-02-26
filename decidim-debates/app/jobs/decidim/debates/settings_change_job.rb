# frozen_string_literal: true

module Decidim
  module Debates
    class SettingsChangeJob < ApplicationJob
      def perform(feature_id, previous_settings, current_settings)
        return if unchanged?(previous_settings, current_settings)

        feature = Decidim::Feature.find(feature_id)

        if debate_creation_enabled?(previous_settings, current_settings)
          event = "decidim.events.debates.creation_enabled"
          event_class = Decidim::Debates::CreationEnabledEvent
        elsif debate_creation_disabled?(previous_settings, current_settings)
          event = "decidim.events.debates.creation_disabled"
          event_class = Decidim::Debates::CreationDisabledEvent
        end

        Decidim::EventsManager.publish(
          event: event,
          event_class: event_class,
          resource: feature,
          recipient_ids: feature.participatory_space.followers.pluck(:id)
        )
      end

      private

      def unchanged?(previous_settings, current_settings)
        current_settings[:creation_enabled] == previous_settings[:creation_enabled]
      end

      def debate_creation_enabled?(previous_settings, current_settings)
        current_settings[:creation_enabled] == true &&
          previous_settings[:creation_enabled] == false
      end

      def debate_creation_disabled?(previous_settings, current_settings)
        current_settings[:creation_enabled] == false &&
          previous_settings[:creation_enabled] == true
      end
    end
  end
end
