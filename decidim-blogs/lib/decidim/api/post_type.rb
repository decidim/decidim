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
    end
  end
end
