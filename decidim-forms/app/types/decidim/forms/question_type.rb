# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionType < GraphQL::Schema::Object
      graphql_name "Question"
      description "A question in a questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "ID of this question"
      field :body, Decidim::Core::TranslatedFieldType, null: false, description: "What is being asked in this question."
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this question."
      field :mandatory, Boolean, null: false, description: "Whether if this question is mandatory."
      field :position, Int, null: true, description: "Order position of the question in the questionnaire"
      field :maxChoices, Int, null: true, description: "On questions with answer options, maximum number of choices the user has" do
        def resolve(object:, _args:, context:)
          object.max_choices
        end
      end
      field :questionType, String, null: true, description: "Type of question." do
        def resolve(object:, _args:, context:)
          object.question_type
        end
      end
      field :answerOptions, [AnswerOptionType], null: false, description: "List of answer options in multi-choice questions." do
        def resolve(object:, _args:, context:)
          object.answer_options
        end
      end
    end
  end
end
