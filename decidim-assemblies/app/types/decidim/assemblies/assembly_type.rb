# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents a assembly.
    class AssemblyType < GraphQL::Schema::Object
      graphql_name "Assembly"
      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::ParticipatorySpaceResourceableInterface
      implements Decidim::Core::TimestampsInterface

      description "An assembly"

      field :id, ID, null: false, description: "The internal ID for this assembly"
      field :subtitle, Decidim::Core::TranslatedFieldType, null: true, description: "The subtitle of this assembly"
      field :shortDescription, Decidim::Core::TranslatedFieldType, null: true, description:"The sort description of this assembly"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description: "The description of this assembly"
      field :slug, String,null: false, description: "The slug of this assembly"
      field :hashtag, String, null: true, description:"The hashtag for this assembly"
      field :publishedAt, Decidim::Core::DateTimeType, null: false, description: "The time this assembly was published"
      field :reference, String, null: false, description:"Reference for this assembly"
      field :categories, [Decidim::Core::CategoryType], null: false, description: "Categories for this assembly"
      field :heroImage, String, null: true, description:"The hero image for this assembly"
      field :bannerImage, String, null: true, description:"The banner image for this assembly"
      field :promoted, Boolean, null: true, description:"If this assembly is promoted (therefore in the homepage)"
      field :developerGroup, Decidim::Core::TranslatedFieldType, null: true, description:"The promoter group of this assembly"
      field :metaScope, Decidim::Core::TranslatedFieldType, null: true, description:"The scope metadata of this assembly"
      field :localArea, Decidim::Core::TranslatedFieldType, null: true, description:"The organization area of this assembly"
      field :target, Decidim::Core::TranslatedFieldType, null: true, description:"Who participates in this assembly"
      field :participatoryScope, Decidim::Core::TranslatedFieldType, null: true, description:"What is decided on this assembly"
      field :participatoryStructure, Decidim::Core::TranslatedFieldType, null: true, description:"How it is decided on this assembly"
      field :showStatistics, Boolean, null: true, description:"If this assembly should show statistics"
      field :scopesEnabled, Boolean, null: true, description:"If this assembly has scopes enabled"
      field :privateSpace, Boolean, null: true, description:"If this assembly is a private space"
      field :area, Decidim::Core::AreaApiType, null: true, description:"Area of this assembly"
      field :parent, Decidim::Assemblies::AssemblyType,null: true, description: "The parent assembly of this assembly"
      field :parentsPath, String, null: true, description:"Assembly hierarchy representation"
      field :childrenCount, Int,null: true, description: "Number of children assemblies"
      field :purposeOfAction, Decidim::Core::TranslatedFieldType, null: true, description:"Purpose of action"
      field :composition, Decidim::Core::TranslatedFieldType, null: true, description:"Composition of this assembly"
      field :assemblyType, Decidim::Assemblies::AssembliesTypeType, null: true, description:"Type of the assembly"
      field :creationDate, Decidim::Core::DateType, null: true, description:"Creation date of this assembly"
      field :createdBy, String, null: true, description:"The creator of this assembly"
      field :createdByOther, Decidim::Core::TranslatedFieldType, null: true, description:"Custom creator"
      field :duration, Decidim::Core::DateType,null: true, description: "Duration of this assembly"
      field :includedAt, Decidim::Core::DateType, null: true, description:"Included at"
      field :closingDate, Decidim::Core::DateType, null: true, description:"Closing date of the assembly"
      field :closingDateReason, Decidim::Core::TranslatedFieldType, null: true, description:"Closing date reason of this assembly"
      field :internalOrganisation, Decidim::Core::TranslatedFieldType, null: true, description:"Internal organisation of this assembly"
      field :isTransparent, Boolean, null: true, description:"If this assembly is transparent"
      field :specialFeatures, Decidim::Core::TranslatedFieldType, null: true, description:"Special features of this assembly"
      field :twitterHandler, String, null: true, description:"Twitter handler"
      field :instagramHandler, String,null: true, description: "Instagram handler"
      field :facebookHandler, String,null: true, description: "Facebook handler"
      field :youtubeHandler, String, null: true, description:"Youtube handler"
      field :githubHandler, String, null: true, description:"Github handler"

      field :members, [Decidim::Assemblies::AssemblyMemberType], null: false, description:"Members of this assembly"
      field :children, [Decidim::Assemblies::AssemblyType],null: false, description: "Childrens of this assembly"

      def shortDescription
        object.short_description
      end
      def publishedAt
        object.published_at
      end

      def heroImage
        object.hero_image
      end
      def bannerImage
        object.banner_image
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
      def participatoryScope
        object.participatory_scope
      end
      def participatoryStructure
        object.participatory_structure
      end
      def showStatistics
        object.show_statistics
      end
      def scopesEnabled
        object.scopes_enabled
      end
      def privateSpace
        object.private_space
      end
      def parentsPath
        object.parents_path
      end
      def childrenCount
        object.children_count
      end
      def createdBy
        object.created_by
      end
      def creationDate
        object.creation_date
      end
      def assemblyType
        object.assembly_type
      end
      def purposeOfAction
        object.purpose_of_action
      end
      def createdByOther
        object.created_by_other
      end
      def isTransparent
        object.is_transparent
      end
      def internalOrganisation
        object.internal_organisation
      end
      def closingDateReason
        object.closing_date_reason
      end
      def closingDate
        object.closing_date
      end
      def includedAt
        object.included_at
      end
      def specialFeatures
        object.special_features
      end
      def twitterHandler
        object.twitter_handler
      end
      def instagramHandler
        object.instagram_handler
      end
      def facebookHandler
        object.facebook_handler
      end
      def youtubeHandler
        object.youtube_handler
      end
      def githubHandler
        object.github_handler
      end
    end
  end
end
