# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcessType.
    class ParticipatoryProcessTypeType < Decidim::Api::Types::BaseObject
      description "A participatory process type"

      field :id, GraphQL::Types::ID, "Unique ID of this participatory process type", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this participatory process type", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this participatory process type was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this participatory process type was updated", null: false
      field :processes, [Decidim::ParticipatoryProcesses::ParticipatoryProcessType, { null: true }],
            description: "Lists all the participatory processes belonging to this type", null: false
    end
  end
end
