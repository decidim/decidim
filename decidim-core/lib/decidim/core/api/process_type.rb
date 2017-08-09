# frozen_string_literal: true

module Decidim
  # This type represents a ParticipatoryProcess.
  ProcessType = GraphQL::ObjectType.define do
    name "Process"
    description "A participatory process"

    field :id, !types.ID, "The Process' unique ID"

    field :title, !TranslatedFieldType, "The title of this process."

    connection :steps, ProcessStepType.connection_type do
      description "All the steps of this process."
    end
  end
end
