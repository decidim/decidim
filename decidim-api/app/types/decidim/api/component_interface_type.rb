# frozen_string_literal: true
module Decidim
  module Api
    ComponentInterfaceType = GraphQL::InterfaceType.define do
      name "ComponentInterfaceType"
      description "Interface for components"

      field :id, types.ID
      field :name, TranslatedFieldType, "The name of this component"
      field :manifest_name, types.String, "The kind of component"

      field :step, ProcessStepType, "The step of this component."
    end
  end
end
