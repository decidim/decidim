# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    class ParticipatoryProcessGroupType < Decidim::Api::Types::BaseObject
      description "A participatory process group"

      implements Decidim::Core::TimestampsInterface

      field :description, Decidim::Core::TranslatedFieldType, "The description of this participatory process group", null: true
      field :developer_group, Decidim::Core::TranslatedFieldType, "The promoter group of this participatory process group", null: true
      field :hashtag, GraphQL::Types::String, "The hashtag for this participatory process group", null: true
      field :hero_image, GraphQL::Types::String, "The hero image for this participatory process group", null: true
      field :id, GraphQL::Types::ID, "ID of this participatory process group", null: false
      field :local_area, Decidim::Core::TranslatedFieldType, "The organization area of this participatory process group", null: true
      field :meta_scope, Decidim::Core::TranslatedFieldType, "The scope metadata of this participatory process group", null: true
      field :participatory_processes, [Decidim::ParticipatoryProcesses::ParticipatoryProcessType, { null: true }],
            description: "Lists all the participatory processes belonging to this group", null: false
      field :participatory_scope, Decidim::Core::TranslatedFieldType, "What is decided on this participatory process group", null: true
      field :participatory_structure, Decidim::Core::TranslatedFieldType, "How it is decided on this participatory process group", null: true
      field :promoted, GraphQL::Types::Boolean, "If this participatory process group is promoted (therefore in the homepage)", null: true
      field :target, Decidim::Core::TranslatedFieldType, "Who participates in this participatory process group", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this participatory process group", null: true

      def hero_image
        object.attached_uploader(:hero_image).url
      end
    end
  end
end
