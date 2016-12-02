# frozen_string_literal: true
module Decidim
  module Api
    # This type represents a step on a participatory process.
    ProcessStepType = GraphQL::ObjectType.define do
      name "ParticipatoryProcessStep"
      description "A participatory process step"

      field :id, !types.ID, "The unique ID of this step."

      field :process do
        type ProcessType
        description "The participatory process in which this step belongs to."
        property :participatory_process
      end

      field :title, TranslatedFieldType, "The title of this step"

      field :shortDescription do
        type TranslatedFieldType
        description "A short description of the step."
        property :short_description
      end

      field :components do
        type !types[ComponentInterfaceType]
        description "Components present on this step"
      end
    end
  end
end
