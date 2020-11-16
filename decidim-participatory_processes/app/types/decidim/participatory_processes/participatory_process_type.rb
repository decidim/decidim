# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.

    class ParticipatoryProcessType  < GraphQL::Schema::Object
      graphql_name "ParticipatoryProcess"

      interfaces [
        -> { Decidim::Core::ParticipatorySpaceInterface },
        -> { Decidim::Core::ParticipatorySpaceResourceableInterface },
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface }
      ]

      description "A participatory process"

      field :id, ID, null: false, description: "The internal ID for this participatory process"
      field :slug, String, null: false
      field :hashtag, String, null: true, description: "The hashtag for this participatory process"
      field :createdAt, Decidim::Core::DateTimeType, null: true, description: "The time this page was created"
      field :updatedAt, Decidim::Core::DateTimeType,null: true, description: "The time this page was updated"
      field :publishedAt, Decidim::Core::DateTimeType, null: true, description: "The time this page was published"
      field :subtitle, Decidim::Core::TranslatedFieldType, null: false, description: "The subtitle of this participatory process."
      field :description, Decidim::Core::TranslatedFieldType, null: false, description: "The description of this participatory process."
      field :shortDescription, Decidim::Core::TranslatedFieldType, null: false , description:  "The short description of this participatory process."
      field :startDate, Decidim::Core::DateType, null: false , description: "This participatory process' start date."
      field :endDate, Decidim::Core::DateType, null: false, description: "This participatory process' end date."

      field :bannerImage, String, null: false, description: "The banner image for this participatory process"
      field :heroImage, String,null: false, description: "The hero image for this participatory process"
      field :promoted, Boolean, null: false, description:"If this participatory process is promoted (therefore in the homepage)"
      field :developerGroup, Decidim::Core::TranslatedFieldType, null: false, description:"The promoter group of this participatory process."
      field :metaScope, Decidim::Core::TranslatedFieldType,null: false, description: "The scope metadata of this participatory process."
      field :localArea, Decidim::Core::TranslatedFieldType, null: false, description:"The organization area of this participatory process."
      field :target, Decidim::Core::TranslatedFieldType, null: false, description:"Who participates in this participatory process."
      field :participatoryScope, Decidim::Core::TranslatedFieldType,null: false, description: "What is decided on this participatory process."
      field :participatoryStructure, Decidim::Core::TranslatedFieldType, null: false, description:"How it is decided on this participatory process."
      field :showMetrics, Boolean, null: false, description: "If this participatory process should show metrics"
      field :showStatistics, Boolean, null: false, description: "If this participatory process should show statistics"
      field :scopesEnabled, Boolean, null: false, description: "If this participatory process has scopes enabled"
      field :announcement, Decidim::Core::TranslatedFieldType, null: false, description: "Highlighted announcement for this participatory process."
      field :reference, String, null: false, description: "Reference prefix for this participatory process"
      field :steps, [ParticipatoryProcessStepType], null: true, description: "All the steps of this process."
      field :categories, [Decidim::Core::CategoryType], null: true, description: "Categories for this participatory process"
      field :participatoryProcessGroup, ParticipatoryProcessGroupType, null: false, description: "The participatory process group in which this process belong to"

      def participatoryScope
        object.participatory_scope
      end

      def participatoryStructure
        object.participatory_structure
      end

      def developerGroup
        object.developer_group
      end

      def metaScope
        object.meta_scope
      end

      def localArea
        object.local_area
      end

      def bannerImage
        object.banner_image
      end

      def heroImage
        object.hero_image
      end

      def publishedAt
        object.published_at
      end

      def startDate
        object.start_date
      end

      def endDate
        object.end_date
      end

      def shortDescription
        object.short_description
      end

      def showMetrics
        object.show_metrics
      end

      def showStatistics
        object.show_statistics
      end

      def scopesEnabled
        object.scopes_enabled
      end

      def participatoryProcessGroup
        object.participatory_process_group
      end

      def createdAt
        object.created_at
      end

      def updatedAt
        object.updated_at
      end
    end
  end
end
