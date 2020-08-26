# frozen_string_literal: true

module Decidim
  module Surveys
    SurveyType = GraphQL::ObjectType.define do
      name "Survey"
      description "A survey"

      field :id, !types.ID, "The internal ID for this survey"
      field :createdAt, Decidim::Core::DateTimeType, "The time this survey was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this survey was updated", property: :updated_at
      field :questionnaire, Decidim::Forms::QuestionnaireType, "The questionnaire for this survey"
    end
  end
end
