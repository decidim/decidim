# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    ParticipatoryProcessGroupType = GraphQL::ObjectType.define do
      name "ParticipatoryProcessGroup"
      description "A participatory process group"

      field :id, !types.ID, "ID of this participatory process group"
      field :title, Decidim::Core::TranslatedFieldType, "The title of this participatory process group"
      field :description, Decidim::Core::TranslatedFieldType, "The description of this participatory process group", property: :description
      field :participatoryProcesses, !types[ParticipatoryProcessType] do
        description "Lists all the participatory processes belonging to this group"
        property :participatory_processes
      end
      field :heroImage, types.String, "The hero image for this participatory process group", property: :hero_image
    end
  end
end
