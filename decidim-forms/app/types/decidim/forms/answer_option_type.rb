# frozen_string_literal: true

module Decidim
  module Forms
    AnswerOptionType = GraphQL::ObjectType.define do
      name "AnswerOption"
      description "An answer option for a multi-choice question in a questionnaire"

      field :id, !types.ID, "ID of this answer option"
      field :body, !Decidim::Core::TranslatedFieldType, "The text answer response option."
      field :freeText, !types.Boolean, "Whether if this answer accepts any free text from the user.", property: :free_text
    end
  end
end
