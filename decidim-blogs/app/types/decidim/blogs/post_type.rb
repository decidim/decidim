# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    PostType = GraphQL::ObjectType.define do

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::EndorsableInterface
      implements Decidim::Core::TimestampsInterface

      name "Post"
      description "A post"

      field :id, !types.ID, "The internal ID of this post"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this post"
      field :body, Decidim::Core::TranslatedFieldType, "The body of this post"
    end
  end
end
