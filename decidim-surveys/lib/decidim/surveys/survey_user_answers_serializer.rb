# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes the answers given by a User for survey so can be
    # exported to CSV, JSON or other formats.
    class SurveyUserAnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a collection of SurveyAnswers.
      def initialize(survey_answers)
        @survey_answers = survey_answers
      end

      # Public: Exports a hash with the serialized data for the user answers.
      def serialize
        @survey_answers.inject({}) do |serialized, answer|
          serialized.update(translated_attribute(answer.question.body) => translated_attribute(answer.body))
        end
      end
    end
  end
end
