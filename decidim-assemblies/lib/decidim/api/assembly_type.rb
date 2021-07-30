# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    class AssemblyType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::ParticipatorySpaceResourceableInterface
      implements Decidim::Core::CategoriesContainerInterface

      description "An assembly"

      field :id, ID, "The internal ID for this assembly", null: false
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this assembly", null: true
      field :short_description, Decidim::Core::TranslatedFieldType, "The sort description of this assembly", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this assembly", null: true
      field :slug, String, "The slug of this assembly", null: false
      field :hashtag, String, "The hashtag for this assembly", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this assembly was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this assembly was updated", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this assembly was published", null: false
      field :reference, String, "Reference for this assembly", null: false

      field :hero_image, String, "The hero image for this assembly", null: true
      field :banner_image, String, "The banner image for this assembly", null: true
      field :promoted, Boolean, "If this assembly is promoted (therefore in the homepage)", null: true
      field :developer_group, Decidim::Core::TranslatedFieldType, "The promoter group of this assembly", null: true
      field :meta_scope, Decidim::Core::TranslatedFieldType, "The scope metadata of this assembly", null: true
      field :local_area, Decidim::Core::TranslatedFieldType, "The organization area of this assembly", null: true
      field :target, Decidim::Core::TranslatedFieldType, "Who participates in this assembly", null: true
      field :participatory_scope, Decidim::Core::TranslatedFieldType, "What is decided on this assembly", null: true
      field :participatory_structure, Decidim::Core::TranslatedFieldType, "How it is decided on this assembly", null: true
      field :show_statistics, Boolean, "If this assembly should show statistics", null: true
      field :scopes_enabled, Boolean, "If this assembly has scopes enabled", null: true
      field :private_space, Boolean, "If this assembly is a private space", null: true
      field :area, Decidim::Core::AreaApiType, "Area of this assembly", null: true
      field :parent, Decidim::Assemblies::AssemblyType, "The parent assembly of this assembly", null: true
      field :parents_path, String, "Assembly hierarchy representation", null: true
      field :children_count, Integer, "Number of children assemblies", null: true
      field :purpose_of_action, Decidim::Core::TranslatedFieldType, "Purpose of action", null: true
      field :composition, Decidim::Core::TranslatedFieldType, "Composition of this assembly", null: true
      field :assembly_type, Decidim::Assemblies::AssembliesTypeType, "Type of the assembly", null: true
      field :creation_date, Decidim::Core::DateType, "Creation date of this assembly", null: true
      field :created_by, String, "The creator of this assembly", null: true
      field :created_by_other, Decidim::Core::TranslatedFieldType, "Custom creator", null: true
      field :duration, Decidim::Core::DateType, "Duration of this assembly", null: true
      field :included_at, Decidim::Core::DateType, "Included at", null: true
      field :closing_date, Decidim::Core::DateType, "Closing date of the assembly", null: true
      field :closing_date_reason, Decidim::Core::TranslatedFieldType, "Closing date reason of this assembly", null: true
      field :internal_organisation, Decidim::Core::TranslatedFieldType, "Internal organisation of this assembly", null: true
      field :is_transparent, Boolean, "If this assembly is transparent", null: true
      field :special_features, Decidim::Core::TranslatedFieldType, "Special features of this assembly", null: true
      field :twitter_handler, String, "Twitter handler", null: true
      field :instagram_handler, String, "Instagram handler", null: true
      field :facebook_handler, String, "Facebook handler", null: true
      field :youtube_handler, String, "Youtube handler", null: true
      field :github_handler, String, "Github handler", null: true
      field :announcement, Decidim::Core::TranslatedFieldType, "Highlighted announcement for this assembly", null: true

      field :members, [Decidim::Assemblies::AssemblyMemberType, { null: true }], "Members of this assembly", null: false
      field :children, [Decidim::Assemblies::AssemblyType, { null: true }], "Childrens of this assembly", null: false

      def hero_image
        object.attached_uploader(:hero_image).path
      end

      def banner_image
        object.attached_uploader(:banner_image).path
      end
    end
  end
end
