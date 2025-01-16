# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    class PostType < Decidim::Api::Types::BaseObject
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::EndorsableInterface
      implements Decidim::Core::TimestampsInterface

      description "A post"

      field :id, GraphQL::Types::ID, "The internal ID of this post", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this post", null: true
      field :body, Decidim::Core::TranslatedFieldType, "The body of this post", null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this page was published", null: false

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
