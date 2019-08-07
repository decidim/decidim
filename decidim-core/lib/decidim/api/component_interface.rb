# frozen_string_literal: true

module Decidim
  module Core
    ComponentInterface = GraphQL::InterfaceType.define do
      name "ComponentInterface"
      description "This interface is implemented by all components that belong into a Participatory Space"

      field :id, !types.ID, "The Component's unique ID"

      field :name, !TranslatedFieldType, "The name of this component."

      field :weight, !types.Int, "The weight of the component"

      field :participatorySpace, !ParticipatorySpaceType, "The participatory space in which this component belongs to.", property: :participatory_space

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
