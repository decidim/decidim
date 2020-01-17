# frozen_string_literal: true

module Decidim
  module Core
    # This interface should be implemented by any Type that can be used as amendment
    # The only requirement is to have an ID and the Type name be the class.name + Type
    AmendableEntityInterface = GraphQL::InterfaceType.define do
      name "AmendableEntityInterface"
      description "An interface that can be used in objects with amendments"

      field :id, !types.ID, "ID of this entity"

      resolve_type ->(obj, _ctx) {
        "#{obj.class.name}Type".constantize
      }
    end
  end
end
