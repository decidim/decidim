# frozen_string_literal: true

module Decidim
  module Forms
    # This interface should be implemented by any Type that can be linked to a questionnaire
    # The only requirement is to have an ID and the Type name be the class.name + Type
    QuestionnaireEntityInterface = GraphQL::InterfaceType.define do
      name "QuestionnaireEntityInterface"
      description "An interface that can be used in objects with questionnaires"

      field :id, !types.ID, "ID of this entity"

      resolve_type ->(obj, _ctx) {
        "#{obj.class.name}Type".constantize
      }
    end
  end
end
