# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.

    class ParticipatoryProcessType < GraphQL::Schema::Object
      graphql_name "ParticipatoryProcess"

      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ParticipatorySpaceResourceableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TimestampsInterface

      description "A participatory process"

      field :id, ID, null: false, description: "The internal ID for this participatory process"
      field :slug, String, null: false
      field :hashtag, String, null: true, description: "The hashtag for this participatory process"
      field :publishedAt, Decidim::Core::DateTimeType, null: true, description: "The time this page was published"
      field :subtitle, Decidim::Core::TranslatedFieldType, null: false, description: "The subtitle of this participatory process."
      field :description, Decidim::Core::TranslatedFieldType, null: false, description: "The description of this participatory process."
      field :shortDescription, Decidim::Core::TranslatedFieldType, null: false, description: "The short description of this participatory process."
      field :startDate, Decidim::Core::DateType, null: false, description: "This participatory process' start date."
      field :endDate, Decidim::Core::DateType, null: false, description: "This participatory process' end date."

      field :bannerImage, String, null: false, description: "The banner image for this participatory process"
      field :heroImage, String, null: false, description: "The hero image for this participatory process"
      field :promoted, Boolean, null: false, description: "If this participatory process is promoted (therefore in the homepage)"
      field :developerGroup, Decidim::Core::TranslatedFieldType, null: false, description: "The promoter group of this participatory process."
      field :metaScope, Decidim::Core::TranslatedFieldType, null: false, description: "The scope metadata of this participatory process."
      field :localArea, Decidim::Core::TranslatedFieldType, null: false, description: "The organization area of this participatory process."
      field :target, Decidim::Core::TranslatedFieldType, null: false, description: "Who participates in this participatory process."
      field :participatoryScope, Decidim::Core::TranslatedFieldType, null: false, description: "What is decided on this participatory process."
      field :participatoryStructure, Decidim::Core::TranslatedFieldType, null: false, description: "How it is decided on this participatory process."
      field :showMetrics, Boolean, null: false, description: "If this participatory process should show metrics"
      field :showStatistics, Boolean, null: false, description: "If this participatory process should show statistics"
      field :scopesEnabled, Boolean, null: false, description: "If this participatory process has scopes enabled"
      field :announcement, Decidim::Core::TranslatedFieldType, null: false, description: "Highlighted announcement for this participatory process."
      field :reference, String, null: false, description: "Reference prefix for this participatory process"
      field :steps, [ParticipatoryProcessStepType], null: true, description: "All the steps of this process."
      field :categories, [Decidim::Core::CategoryType], null: true, description: "Categories for this participatory process"
      field :participatoryProcessGroup, ParticipatoryProcessGroupType, null: false, description: "The participatory process group in which this process belong to"

      def participatoryScope(object:, args:, context:)
        object.participatory_scope
      end

      def participatoryStructure(object:, args:, context:)
        object.participatory_structure
      end

      def developerGroup(object:, args:, context:)
        object.developer_group
      end

      def metaScope(object:, args:, context:)
        object.meta_scope
      end

      def localArea(object:, args:, context:)
        object.local_area
      end

      def bannerImage(object:, args:, context:)
        object.banner_image
      end

      def heroImage(object:, args:, context:)
        object.hero_image
      end

      def publishedAt(object:, args:, context:)
        object.published_at
      end

      def startDate(object:, args:, context:)
        object.start_date
      end

      def endDate(object:, args:, context:)
        object.end_date
      end

      def shortDescription(object:, args:, context:)
        object.short_description
      end

      def showMetrics(object:, args:, context:)
        object.show_metrics
      end

      def showStatistics(object:, args:, context:)
        object.show_statistics
      end

      def scopesEnabled(object:, args:, context:)
        object.scopes_enabled
      end

      def participatoryProcessGroup(object:, args:, context:)
        object.participatory_process_group
      end

      def createdAt(object:, args:, context:)
        object.created_at
      end

      def updatedAt(object:, args:, context:)
        object.updated_at
      end
    end
  end
end
