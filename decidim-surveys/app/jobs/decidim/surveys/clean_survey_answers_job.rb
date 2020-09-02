# frozen_string_literal: true

module Decidim
  module Surveys
    class CleanSurveyAnswersJob < ApplicationJob
      def perform(_event_name, data)
        @component = data[:resource]
        return unless component&.manifest_name == "surveys"

        @survey = Survey.find_by(component: component)
        return unless survey&.questionnaire

        case data[:event_class]
        when "Decidim::ComponentPublishedEvent"
          clean_answers
        end
      end

      private

      attr_reader :survey, :component

      def clean_answers
        return unless survey.clean_after_publish?

        survey.questionnaire.answers.destroy_all
        component.settings[:clean_after_publish] = false
        component.save
      end
    end
  end
end
