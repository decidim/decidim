# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    PostType = GraphQL::ObjectType.define do
      interfaces [
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::AttachableInterface }
      ]

      name "Post"
      description "A post"

      field :id, !types.ID, "The internal ID of this post"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this post"
      field :body, Decidim::Core::TranslatedFieldType, "The body of this post"
      field :createdAt, Decidim::Core::DateTimeType, "The time this post was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this post was updated", property: :updated_at

      field :author, !Decidim::Core::AuthorInterface, "The author of this post"
    end
  end
end
