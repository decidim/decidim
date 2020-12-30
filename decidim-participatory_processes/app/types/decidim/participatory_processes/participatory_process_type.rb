# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    class ParticipatoryProcessType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ParticipatorySpaceResourceableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface

      description "A participatory process"

      field :id, ID, "The internal ID for this participatory process", null: false
      field :slug, String, null: false
      field :hashtag, String, "The hashtag for this participatory process", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this page was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this page was updated", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this page was published", null: false
      field :subtitle, Decidim::Core::TranslatedFieldType, "The subtitle of this participatory process.", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this participatory process.", null: true
      field :short_description, Decidim::Core::TranslatedFieldType, "The short description of this participatory process.", null: true
      field :start_date, Decidim::Core::DateType, "This participatory process' start date.", null: true
      field :end_date, Decidim::Core::DateType, "This participatory process' end date.", null: true

      field :banner_image, String, "The banner image for this participatory process", null: true
      field :hero_image, String, "The hero image for this participatory process", null: true
      field :promoted, Boolean, "If this participatory process is promoted (therefore in the homepage)", null: true
      field :developer_group, Decidim::Core::TranslatedFieldType, "The promoter group of this participatory process.", null: true
      field :meta_scope, Decidim::Core::TranslatedFieldType, "The scope metadata of this participatory process.", null: true
      field :local_area, Decidim::Core::TranslatedFieldType, "The organization area of this participatory process.", null: true
      field :target, Decidim::Core::TranslatedFieldType, "Who participates in this participatory process.", null: true
      field :participatory_scope, Decidim::Core::TranslatedFieldType, "What is decided on this participatory process.", null: true
      field :participatory_structure, Decidim::Core::TranslatedFieldType, "How it is decided on this participatory process.", null: true
      field :show_metrics, Boolean, "If this participatory process should show metrics", null: true
      field :show_statistics, Boolean, "If this participatory process should show statistics", null: true
      field :scopes_enabled, Boolean, "If this participatory process has scopes enabled", null: true

      field :announcement, Decidim::Core::TranslatedFieldType, "Highlighted announcement for this participatory process.", null: true

      field :reference, String, "Reference prefix for this participatory process", null: true
      field :steps, [ParticipatoryProcessStepType, { null: true }], "All the steps of this process.", null: false
      field :categories, [Decidim::Core::CategoryType, { null: true }], "Categories for this participatory process", null: false

      field :participatory_process_group, ParticipatoryProcessGroupType, description: "The participatory process group in which this process belong to", null: true
    end
  end
end
