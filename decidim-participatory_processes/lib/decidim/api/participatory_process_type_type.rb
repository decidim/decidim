# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcessType.
    class ParticipatoryProcessTypeType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A participatory process type"

      field :id, GraphQL::Types::ID, "Unique ID of this participatory process type", null: false
      field :processes, [Decidim::ParticipatoryProcesses::ParticipatoryProcessType, { null: true }],
            description: "Lists all the participatory processes belonging to this type", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this participatory process type", null: true
    end
  end
end
