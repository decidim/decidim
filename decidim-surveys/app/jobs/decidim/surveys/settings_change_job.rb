# frozen_string_literal: true

module Decidim
  module Surveys
    class SettingsChangeJob < ApplicationJob
      def perform(component_id, previous_settings, current_settings)
        return if unchanged?(previous_settings, current_settings)

        component = Decidim::Component.find(component_id)

        if survey_opened?(previous_settings, current_settings)
          event = "decidim.events.surveys.survey_opened"
          event_class = Decidim::Surveys::OpenedSurveyEvent
        elsif survey_closed?(previous_settings, current_settings)
          event = "decidim.events.surveys.survey_closed"
          event_class = Decidim::Surveys::ClosedSurveyEvent
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
        current_settings[:allow_responses] == previous_settings[:allow_responses]
      end

      # rubocop:disable Style/DoubleNegation
      def survey_opened?(previous_settings, current_settings)
        current_settings[:allow_responses] == true &&
          !!previous_settings[:allow_responses] == false
      end

      def survey_closed?(previous_settings, current_settings)
        !!current_settings[:allow_responses] == false &&
          previous_settings[:allow_responses] == true
      end

      def clean_after_publish_changed?(previous_settings, current_settings)
        current_settings[:clean_after_publish] != previous_settings[:clean_after_publish]
      end
      # rubocop:enable Style/DoubleNegation
    end
  end
end
