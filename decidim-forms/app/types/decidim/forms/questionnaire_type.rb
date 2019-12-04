# frozen_string_literal: true

module Decidim
  module Forms
    QuestionnaireType = GraphQL::ObjectType.define do
      name "Questionnaire"
      description "A questionnaire"

      interfaces [
        -> { Decidim::Core::TimestampsInterface }
      ]

      field :id, !types.ID, "ID of this questionnaire"
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this questionnaire."
      field :description, Decidim::Core::TranslatedFieldType, "The description of this questionnaire."
      field :tos, Decidim::Core::TranslatedFieldType, "The Terms of Service for this questionnaire."
      field :forType, types.String, "Type of entity using this questionnaire.", property: :questionnaire_for_type
      field :forEntity, QuestionnaireEntityInterface, "Entity using this questionnaire.", property: :questionnaire_for
      field :questions, !types[QuestionType], "Questions in this questionnaire."
    end
  end
end
