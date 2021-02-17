# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerOptionType < Decidim::Api::Types::BaseObject
      description "An answer option for a multi-choice question in a questionnaire"

      field :id, GraphQL::Types::ID, "ID of this answer option", null: false
      field :body, Decidim::Core::TranslatedFieldType, "The text answer response option.", null: false
      field :free_text, GraphQL::Types::Boolean, "Whether if this answer accepts any free text from the user.", null: false
    end
  end
end
