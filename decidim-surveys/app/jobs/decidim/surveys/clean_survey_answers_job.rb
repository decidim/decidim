# frozen_string_literal: true

module Decidim
  module Surveys
    class CleanSurveyAnswersJob < ApplicationJob
      def perform(_event_name, data)
        return unless data[:resource]&.manifest_name == "surveys"

        @survey = Survey.find_by(component: data[:resource])
        return unless survey&.questionnaire

        case data[:event_class]
        when "Decidim::ComponentPublishedEvent"
          clean_answers
        end
      end

      private

      attr_reader :survey

      def clean_answers
        return unless survey.clean_after_publish?

        survey.questionnaire.answers.destroy_all
        survey.update(clean_after_publish: false)
      end
    end
  end
end
