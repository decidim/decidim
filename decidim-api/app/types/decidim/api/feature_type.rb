# frozen_string_literal: true
module Decidim
  module Api
    FeatureType = GraphQL::ObjectType.define do
      name "FeatureType"
      field :id, types.ID
      field :manifest_name, types.String

      field :process, ProcessType, "The participatory process of this feature"

      field :components do
        type !types[ComponentInterfaceType]
        description "Components present on this step"
      end
    end
  end
end
