# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    class ParticipatoryProcessGroupType < Decidim::Api::Types::BaseObject
      description "A participatory process group"

      field :id, GraphQL::Types::ID, "ID of this participatory process group", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this participatory process group", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this participatory process group", null: true
      field :participatory_processes, [Decidim::ParticipatoryProcesses::ParticipatoryProcessType, { null: true }],
            description: "Lists all the participatory processes belonging to this group", null: false
      field :hero_image, GraphQL::Types::String, "The hero image for this participatory process group", null: true

      def hero_image
        object.attached_uploader(:hero_image).path
      end
    end
  end
end
