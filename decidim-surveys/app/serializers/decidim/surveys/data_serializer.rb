# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes the specific data in each Survey.
    # This is `Questionnaire->questions` with their `response_options`,
    # `matrix_rows` and `display_conditions`, but not `responses`
    # and `response_choices`.
    class DataSerializer < Decidim::Exporters::Serializer
      # Returns: Array of Decidim::Forms::Questionnaire as a json hash,
      #     or nil if none exists.
      def serialize
        component = resource
        surveys = Decidim::Surveys::Survey.where(component:)
        surveys.collect do |survey|
          next if survey.questionnaire.nil?

          json = serialize_survey(survey)
          json.with_indifferent_access.merge(survey_id: survey.id)
        end
      end

      def serialize_survey(survey)
        questionnaire = survey.questionnaire
        questionnaire_json = questionnaire.attributes.as_json
        questionnaire_json[:questions] = serialize_questions(
          questionnaire.questions.includes(:response_options, :matrix_rows, :display_conditions).order(:position)
        )
        json = survey.attributes.as_json
        json[:questionnaire] = questionnaire_json
        json
      end

      def serialize_questions(questions)
        questions.collect do |question|
          json = question.attributes.as_json
          json[:response_options] = serialize_response_options(question.response_options)
          json[:matrix_rows] = serialize_matrix_rows(question.matrix_rows)
          json[:display_conditions] = serialize_display_conditions(question.display_conditions)
          json
        end
      end

      def serialize_response_options(response_options)
        response_options.collect do |option|
          option.attributes.as_json
        end
      end

      def serialize_matrix_rows(matrix_rows)
        matrix_rows.collect do |matrix_row|
          matrix_row.attributes.as_json
        end
      end

      def serialize_display_conditions(display_conditions)
        display_conditions.collect do |display_condition|
          display_condition.attributes.as_json
        end
      end
    end
  end
end
