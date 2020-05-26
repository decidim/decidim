# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election Question.
    # The name is different from the model because the Question type is already defined on the Forms module.
    ElectionQuestionType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::TraceableInterface }
      ]

      name "ElectionQuestion"
      description "A question for an election"

      field :id, !types.ID, "The internal ID of this question"
      field :title, !Decidim::Core::TranslatedFieldType, "The title for this question"
      field :description, !Decidim::Core::TranslatedFieldType, "The description for this question"
      field :maxSelections, !types.Int, "The maximum number of posible selections for this question", property: :max_selections
      field :weight, types.Int, "The ordering weight for this question"
      field :randomAnswersOrder, types.Boolean, "Should this question order answers in random order?", property: :random_answers_order

      field :answers, !types[Decidim::Elections::ElectionAnswerType], "The answers for this question"
    end
  end
end
