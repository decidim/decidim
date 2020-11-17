# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionnaireType < GraphQL::Schema::Object
      graphql_name "Questionnaire"

      description "A questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "ID of this questionnaire"
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title of this questionnaire."
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this questionnaire."
      field :tos, Decidim::Core::TranslatedFieldType, null: true, description: "The Terms of Service for this questionnaire."
      field :forType, String, null: true, description: "Type of entity using this questionnaire." do
        def resolve(object:, _args:, context:)
          object.questionnaire_for_type
        end
      end
      field :forEntity, QuestionnaireEntityInterface, null: true, description: "Entity using this questionnaire." do
        def resolve(object:, _args:, context:)
          object.questionnaire_for
        end
      end
      field :questions, [QuestionType], null: false, description: "Questions in this questionnaire."
    end
  end
end
