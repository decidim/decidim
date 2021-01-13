# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    PostType = GraphQL::ObjectType.define do
      Decidim::Blogs::Post.include Decidim::Core::GraphQLApiTransition

      interfaces [
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Core::AuthorableInterface },
        -> { Decidim::Core::TraceableInterface },
        -> { Decidim::Core::EndorsableInterface },
        -> { Decidim::Core::TimestampsInterface }
      ]

      name "Post"
      description "A post"

      field :id, !types.ID, "The internal ID of this post"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this post"
      field :body, Decidim::Core::TranslatedFieldType, "The body of this post"
    end
  end
end
