# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < GraphQL::Schema::Object
      graphql_name "Survey"
      description "A survey"

      field :id, ID, null: false , description: "The internal ID for this survey"
      field :createdAt, Decidim::Core::DateTimeType, null: true , description:"The time this survey was created"
      field :updatedAt, Decidim::Core::DateTimeType, null: true , description:"The time this survey was updated"
      field :questionnaire, Decidim::Forms::QuestionnaireType,null: true , description: "The questionnaire for this survey"

      def createdAt
        object.created_at
      end
      def updatedAt
        object.updated_at
      end
    end
  end
end
