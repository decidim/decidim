# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerOptionType < GraphQL::Schema::Object
      graphql_name "AnswerOption"
      description "An answer option for a multi-choice question in a questionnaire"

      field :id, ID, null: false, description: "ID of this answer option"
      field :body, Decidim::Core::TranslatedFieldType, null: false, description: "The text answer response option."
      field :freeText, Boolean, null: false, description: "Whether if this answer accepts any free text from the user." do
        def resolve(object:, _args:, context:)
          object.free_text
        end
      end
    end
  end
end
