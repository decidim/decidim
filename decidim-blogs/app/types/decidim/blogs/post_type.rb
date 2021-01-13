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

      field :userAllowedToComment, !types.Boolean, "Check if the current user can comment" do
        resolve lambda { |obj, _args, ctx|
          obj.commentable? && obj.user_allowed_to_comment?(ctx[:current_user])
        }
      end

      field :endorsements, !types[Decidim::Core::AuthorInterface], "The endorsements of this object." do
        resolve ->(object, _, _) {
          object.endorsements.map(&:normalized_author)
        }
      end
    end
  end
end
