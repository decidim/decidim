# frozen_string_literal: true

module Decidim
  module Surveys
    # This class serializes the component specific data in a Survey.
    # This is `Questionnaire->questions->answer_options` but not `answers`
    # and `answer_choices`.
    class DataSerializer < Decidim::Exporters::Serializer
      def serialize
        survey = resource
        questionnaire = survey.questionnaire
        json = serialize_questionnaire(questionnaire)
        json.with_indifferent_access
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
