# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < GraphQL::Schema::Object
      graphql_name "Survey"
      description "A survey"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "The internal ID for this survey"
      field :questionnaire, Decidim::Forms::QuestionnaireType, null: true, description: "The questionnaire for this survey"

    end
  end
end
