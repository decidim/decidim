# frozen_string_literal: true

module Decidim
  module Forms
    # This interface should be implemented by any Type that can be linked to a questionnaire
    # The only requirement is to have an ID and the Type name be the class.name + Type
    module QuestionnaireEntityInterface
      include GraphQL::Schema::Interface
      # name "QuestionnaireEntityInterface"
      description "An interface that can be used in objects with questionnaires"

      field :id, ID, null: false, description: "ID of this entity"

      def resolve_type(obj, _ctx)
        "#{obj.class.name}Type".constantize
      end
    end
  end
end
