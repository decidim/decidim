# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    class PostType < Decidim::Api::Types::BaseObject
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::FollowableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::LikeableInterface
      implements Decidim::Core::TimestampsInterface

      description "A post"

      field :body, Decidim::Core::TranslatedFieldType, "The body of this post", null: true
      field :id, GraphQL::Types::ID, "The internal ID of this post", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this page was published", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this post", null: true
      field :url, String, "The URL for this post", null: false

      def url
        Decidim::ResourceLocatorPresenter.new(object).url
      end

      def self.authorized?(object, context)
        context[:post] = object

        chain = [
          allowed_to?(:read, :blogpost, object, context),
          !object.hidden?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
