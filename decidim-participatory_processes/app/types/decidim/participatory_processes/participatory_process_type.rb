# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    ParticipatoryProcessType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::ParticipatorySpaceResourceableInterface },
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface }
      ]

      name "ParticipatoryProcess"
      description "A participatory process"

      field :id, !types.ID, "The internal ID for this participatory process"
      field :slug, !types.String
      field :hashtag, types.String, "The hashtag for this participatory process"
      field :createdAt, !Decidim::Core::DateTimeType, "The time this page was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this page was updated", property: :updated_at
      field :publishedAt, !Decidim::Core::DateTimeType, "The time this page was published", property: :published_at
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this participatory process."
      field :description, Decidim::Core::TranslatedFieldType, "The description of this participatory process.", property: :description
      field :shortDescription, Decidim::Core::TranslatedFieldType, "The short description of this participatory process.", property: :short_description
      field :startDate, Decidim::Core::DateType, "This participatory process' start date.", property: :start_date
      field :endDate, Decidim::Core::DateType, "This participatory process' end date.", property: :end_date

      field :bannerImage, types.String, "The banner image for this participatory process", property: :banner_image
      field :heroImage, types.String, "The hero image for this participatory process", property: :hero_image
      field :promoted, types.Boolean, "If this participatory process is promoted (therefore in the homepage)"
      field :developerGroup, Decidim::Core::TranslatedFieldType, "The promoter group of this participatory process.", property: :developer_group
      field :metaScope, Decidim::Core::TranslatedFieldType, "The scope metadata of this participatory process.", property: :meta_scope
      field :localArea, Decidim::Core::TranslatedFieldType, "The organization area of this participatory process.", property: :local_area
      field :target, Decidim::Core::TranslatedFieldType, "Who participates in this participatory process."
      field :participatoryScope, Decidim::Core::TranslatedFieldType, "What is decided on this participatory process.", property: :participatory_scope
      field :participatoryStructure, Decidim::Core::TranslatedFieldType, "How it is decided on this participatory process.", property: :participatory_structure
      field :showMetrics, types.Boolean, "If this participatory process should show metrics", property: :show_metrics
      field :showStatistics, types.Boolean, "If this participatory process should show statistics", property: :show_statistics
      field :scopesEnabled, types.Boolean, "If this participatory process has scopes enabled", property: :scopes_enabled

      field :announcement, Decidim::Core::TranslatedFieldType, "Highlighted announcement for this participatory process."

      field :reference, types.String, "Reference prefix for this participatory process"
      field :steps, !types[ParticipatoryProcessStepType], "All the steps of this process."
      field :categories, !types[Decidim::Core::CategoryType], "Categories for this participatory process"

      field :participatoryProcessGroup, ParticipatoryProcessGroupType do
        description "The participatory process group in which this process belong to"
        property :participatory_process_group
      end
    end
  end
end
