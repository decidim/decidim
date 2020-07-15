# frozen_string_literal: true

module Decidim
  module Forms
    QuestionType = GraphQL::ObjectType.define do
      name "Question"
      description "A question in a questionnaire"

      interfaces [
        -> { Decidim::Core::TimestampsInterface }
      ]

      field :id, !types.ID, "ID of this question"
      field :body, !Decidim::Core::TranslatedFieldType, "What is being asked in this question."
      field :description, Decidim::Core::TranslatedFieldType, "The description of this question."
      field :mandatory, !types.Boolean, "Whether if this question is mandatory."
      field :position, types.Int, "Order position of the question in the questionnaire"
      field :maxChoices, types.Int, "On questions with answer options, maximum number of choices the user has", property: :max_choices
      field :questionType, types.String, "Type of question.", property: :question_type
      field :answerOptions, !types[AnswerOptionType], "List of answer options in multi-choice questions.", property: :answer_options
    end
  end
end
