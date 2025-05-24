# frozen_string_literal: true

module Decidim
  module Debates
    class DebateType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::FollowableInterface
      implements Decidim::Core::ReferableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::LikeableInterface
      implements Decidim::Core::TraceableInterface

      description "A debate"

      field :closed_at, Decidim::Core::DateTimeType, "The closed time for this debate", null: true
      field :comments_enabled, Boolean, "Whether the comments are enabled for this debate", null: true
      field :conclusions, Decidim::Core::TranslatedFieldType, "The conclusion for this debate", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this debate", null: true
      field :end_time, Decidim::Core::DateTimeType, "The end time for this debate", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this debate", null: false
      field :image, GraphQL::Types::String, "The image of this debate", null: true
      field :information_updates, Decidim::Core::TranslatedFieldType, "The information updates for this debate", null: true
      field :instructions, Decidim::Core::TranslatedFieldType, "The instructions for this debate", null: true
      field :last_comment_at, Decidim::Core::DateTimeType, "The last comment time for this debate", null: true
      field :last_comment_by, Decidim::Core::UserType, "The last commenter for this debate", null: true
      field :start_time, Decidim::Core::DateTimeType, "The start time for this debate", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this debate", null: true
      field :url, GraphQL::Types::String, "The URL for this debate", null: false

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end

      def self.authorized?(object, context)
        context[:debate] = object

        super && allowed_to?(:read, :debate, object, context)
      end
    end
  end
end
