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

        Decidim::EventsManager.publish(
          event: event,
          event_class: event_class,
          resource: component,
          recipient_ids: component.participatory_space.followers.pluck(:id)
        )
      end

      private

      def unchanged?(previous_settings, current_settings)
        current_settings[:allow_answers] == previous_settings[:allow_answers]
      end

      def survey_opened?(previous_settings, current_settings)
        current_settings[:allow_answers] == true &&
          previous_settings[:allow_answers] == false
      end

      def survey_closed?(previous_settings, current_settings)
        current_settings[:allow_answers] == false &&
          previous_settings[:allow_answers] == true
      end
    end
  end
end
