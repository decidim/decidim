# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionnaireType < Decidim::Api::Types::BaseObject
      description "A questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :id, GraphQL::Types::ID, "ID of this questionnaire", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this questionnaire.", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this questionnaire.", null: true
      field :tos, Decidim::Core::TranslatedFieldType, "The Terms of Service for this questionnaire.", null: true
      field :for_type, GraphQL::Types::String, "Type of entity using this questionnaire.", method: :questionnaire_for_type, null: true
      field :for_entity, QuestionnaireEntityInterface, "Entity using this questionnaire.", method: :questionnaire_for, null: true
      field :questions, [Decidim::Forms::QuestionType, { null: true }], "Questions in this questionnaire.", null: false
    end
  end
end
