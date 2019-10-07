# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes the specific data in each Survey.
    # This is `Questionnaire->questions->answer_options` but not `answers`
    # and `answer_choices`.
    class DataSerializer < Decidim::Exporters::Serializer
      # Returns: Array of Decidim::Forms::Questionnaire as a json hash,
      #     or nil if none exists.
      def serialize
        component = resource
        surveys = Decidim::Surveys::Survey.where(component: component)
        surveys.collect do |survey|
          questionnaire = survey.questionnaire
          next if questionnaire.nil?
          json = serialize_questionnaire(questionnaire)
          json.with_indifferent_access.merge(survey_id: survey.id)
        end
      end

      def serialize_questionnaire(questionnaire)
        json = questionnaire.attributes.as_json
        json[:questions] = serialize_questions(questionnaire.questions.order(:position))
        json
      end

      def serialize_questions(questions)
        questions.collect do |question|
          json = question.attributes.as_json
          json[:answer_options] = serialize_answer_options(question.answer_options)
          json
        end
      end

      def serialize_answer_options(answer_options)
        answer_options.collect do |option|
          option.attributes.as_json
        end
      end
    end
  end
end
