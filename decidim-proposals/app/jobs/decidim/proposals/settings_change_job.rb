# frozen_string_literal: true

module Decidim
  module Proposals
    class SettingsChangeJob < ApplicationJob
      def perform(component_id, previous_settings, current_settings)
        component = Decidim::Component.find(component_id)

        if creation_enabled?(previous_settings, current_settings)
          event = "decidim.events.proposals.creation_enabled"
          event_class = Decidim::Proposals::CreationEnabledEvent
        elsif voting_enabled?(previous_settings, current_settings)
          event = "decidim.events.proposals.voting_enabled"
          event_class = Decidim::Proposals::VotingEnabledEvent
        elsif endorsing_enabled?(previous_settings, current_settings)
          event = "decidim.events.proposals.endorsing_enabled"
          event_class = Decidim::Proposals::EndorsingEnabledEvent
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

      # rubocop:disable Style/DoubleNegation
      def creation_enabled?(previous_settings, current_settings)
        current_settings[:creation_enabled] == true &&
          !!previous_settings[:creation_enabled] == false
      end

      def voting_enabled?(previous_settings, current_settings)
        (current_settings[:votes_enabled] == true && !!current_settings[:votes_blocked] == false) &&
          (!!previous_settings[:votes_enabled] == false || previous_settings[:votes_blocked] == true)
      end

      def endorsing_enabled?(previous_settings, current_settings)
        (current_settings[:endorsements_enabled] == true && !!current_settings[:endorsements_blocked] == false) &&
          (!!previous_settings[:endorsements_enabled] == false || previous_settings[:endorsements_blocked] == true)
      end
      # rubocop:enable Style/DoubleNegation
    end
  end
end
