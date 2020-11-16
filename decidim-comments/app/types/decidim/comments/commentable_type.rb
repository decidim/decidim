# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a commentable object.
    CommentableType = GraphQL::ObjectType.define do
      name "Commentable"
      description "A commentable object"

      implements Decidim::Comments::CommentableInterface
    end
  end
end
