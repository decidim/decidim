# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    class ParticipatoryProcessGroupType < GraphQL::Schema::Object
      graphql_name  "ParticipatoryProcessGroup"
      description "A participatory process group"

      field :id, ID, null: false, description:  "ID of this participatory process group"
      field :name, Decidim::Core::TranslatedFieldType, null: true, description: "The name of this participatory process group"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description:  "The description of this participatory process group"
      field :participatoryProcesses, [ParticipatoryProcessType], null: false, description: "Lists all the participatory processes belonging to this group"
      field :heroImage, String, null: true, description: "The hero image for this participatory process group"

      def heroImage
        object.hero_image
      end

      def participatoryProcesses
        object.participatory_processes
      end

    end
  end
end
