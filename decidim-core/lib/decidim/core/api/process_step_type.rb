# frozen_string_literal: true

module Decidim
  # This type represents a step on a participatory process.
  ProcessStepType = GraphQL::ObjectType.define do
    name "ProcessStep"
    description "A participatory process step"

    field :id, !types.ID, "The unique ID of this step."

    field :process do
      type !ProcessType
      description "The participatory process in which this step belongs to."
      property :participatory_process
    end

    field :title, !TranslatedFieldType, "The title of this step"
  end
end
