# frozen_string_literal: true

module Decidim
  module Blogs
    # This type represents a Post.
    class PostType < GraphQL::Schema::Object
      graphql_name "Post"
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::EndorsableInterface
      implements Decidim::Core::TimestampsInterface

      description "A post"

      field :id, ID, null: false, description: "The internal ID of this post"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "The title for this post"
      field :body, Decidim::Core::TranslatedFieldType, null: true, description: "The body of this post"
    end
  end
end
