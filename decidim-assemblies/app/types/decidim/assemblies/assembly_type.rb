# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    AssemblyType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Core::ParticipatorySpaceResourceableInterface }
      ]

      name "Assembly"
      description "An assembly"

      field :id, !types.ID, "The internal ID for this assembly"
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this assembly"
      field :shortDescription, Decidim::Core::TranslatedFieldType, "The sort description of this assembly", property: :short_description
      field :description, Decidim::Core::TranslatedFieldType, "The description of this assembly"
      field :slug, !types.String, "The slug of this assembly"
      field :hashtag, types.String, "The hashtag for this assembly"
      field :createdAt, !Decidim::Core::DateTimeType, "The time this assembly was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this assembly was updated", property: :updated_at
      field :publishedAt, !Decidim::Core::DateTimeType, "The time this assembly was published", property: :published_at
      field :reference, !types.String, "Reference for this assembly"
      field :categories, !types[Decidim::Core::CategoryType], "Categories for this assembly"

      field :heroImage, types.String, "The hero image for this assembly", property: :hero_image
      field :bannerImage, types.String, "The banner image for this assembly", property: :banner_image
      field :promoted, types.Boolean, "If this assembly is promoted (therefore in the homepage)"
      field :developerGroup, Decidim::Core::TranslatedFieldType, "The promoter group of this assembly", property: :developer_group
      field :metaScope, Decidim::Core::TranslatedFieldType, "The scope metadata of this assembly", property: :meta_scope
      field :localArea, Decidim::Core::TranslatedFieldType, "The organization area of this assembly", property: :local_area
      field :target, Decidim::Core::TranslatedFieldType, "Who participates in this assembly"
      field :participatoryScope, Decidim::Core::TranslatedFieldType, "What is decided on this assembly", property: :participatory_scope
      field :participatoryStructure, Decidim::Core::TranslatedFieldType, "How it is decided on this assembly", property: :participatory_structure
      field :showStatistics, types.Boolean, "If this assembly should show statistics", property: :show_statistics
      field :scopesEnabled, types.Boolean, "If this assembly has scopes enabled", property: :scopes_enabled
      field :privateSpace, types.Boolean, "If this assembly is a private space", property: :private_space
      field :area, Decidim::Core::AreaApiType, "Area of this assembly"
      field :parent, Decidim::Assemblies::AssemblyType, "The parent assembly of this assembly"
      field :parentsPath, types.String, "Assembly hierarchy representation", property: :parents_path
      field :childrenCount, types.Int, "Number of children assemblies", property: :children_count
      field :purposeOfAction, Decidim::Core::TranslatedFieldType, "Purpose of action", property: :purpose_of_action
      field :composition, Decidim::Core::TranslatedFieldType, "Composition of this assembly"
      field :assemblyType, Decidim::Assemblies::AssembliesTypeType, "Type of the assembly", property: :assembly_type
      field :creationDate, Decidim::Core::DateType, "Creation date of this assembly", property: :creation_date
      field :createdBy, types.String, "The creator of this assembly", property: :created_by
      field :createdByOther, Decidim::Core::TranslatedFieldType, "Custom creator", property: :created_by_other
      field :duration, Decidim::Core::DateType, "Duration of this assembly"
      field :includedAt, Decidim::Core::DateType, "Included at", property: :included_at
      field :closingDate, Decidim::Core::DateType, "Closing date of the assembly", property: :closing_date
      field :closingDateReason, Decidim::Core::TranslatedFieldType, "Closing date reason of this assembly", property: :closing_date_reason
      field :internalOrganisation, Decidim::Core::TranslatedFieldType, "Internal organisation of this assembly", property: :internal_organisation
      field :isTransparent, types.Boolean, "If this assembly is transparent", property: :is_transparent
      field :specialFeatures, Decidim::Core::TranslatedFieldType, "Special features of this assembly", property: :special_features
      field :twitterHandler, types.String, "Twitter handler", property: :twitter_handler
      field :instagramHandler, types.String, "Instagram handler", property: :instagram_handler
      field :facebookHandler, types.String, "Facebook handler", property: :facebook_handler
      field :youtubeHandler, types.String, "Youtube handler", property: :youtube_handler
      field :githubHandler, types.String, "Github handler", property: :github_handler

      field :members, !types[Decidim::Assemblies::AssemblyMemberType], "Members of this assembly"
      field :children, !types[Decidim::Assemblies::AssemblyType], "Childrens of this assembly"
    end
  end
end
