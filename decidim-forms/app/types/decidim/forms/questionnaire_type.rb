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
    end
  end
end
