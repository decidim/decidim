# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a ParticipatoryProcess.
    ComponentInterface = GraphQL::InterfaceType.define do
      name "ComponentInterface"
      description "A component inside a participatory space"

      field :id, !types.ID, "The Component's unique ID"

      field :name, !TranslatedFieldType, "The name of this component."

      resolve_type ->(obj, _ctx) {
        obj.manifest.api_type.constantize
      }
    end
  end
end
