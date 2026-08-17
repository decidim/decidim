# frozen_string_literal: true

module Decidim
  module Surveys
    class CleanSurveyResponsesJob < ApplicationJob
      def perform(_event_name, data)
        @component = data[:resource]
        return unless component&.manifest_name == "surveys"

        @survey = Survey.find_by(component:)
        return unless survey&.questionnaire

        case data[:event_class]
        when "Decidim::ComponentPublishedEvent"
          clean_responses
        end
      end

      private

      attr_reader :survey, :component
    end
  end
end
