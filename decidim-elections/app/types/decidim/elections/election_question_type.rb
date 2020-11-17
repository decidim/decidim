# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election Question.
    # The name is different from the model because the Question type is already defined on the Forms module.
    class ElectionQuestionType < GraphQL::Schema::Object
      graphql_name "ElectionQuestion"
      implements Decidim::Core::TraceableInterface

      description "A question for an election"

      field :id, ID, null: false, description: "The internal ID of this question"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title for this question"
      field :description, Decidim::Core::TranslatedFieldType, null: false, description: "The description for this question"
      field :maxSelections, Int, null: false, description: "The maximum number of possible selections for this question" do
        def resolve(object:, _args:, context:)
          object.max_selections
        end
      end
      field :weight, Int, null: true, description: "The ordering weight for this question"
      field :randomAnswersOrder, Boolean, null: true, description: "Should this question order answers in random order?" do
        def resolve(object:, _args:, context:)
          object.random_answers_order
        end
      end
      field :minSelections, Int, null: false, description: "The minimum number of possible selections for this question" do
        def resolve(object:, _args:, context:)
          object.min_selections
        end
      end
      field :answers, [Decidim::Elections::ElectionAnswerType], null: false, description: "The answers for this question"
    end
  end
end
