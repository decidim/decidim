# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents a commentable object.
    CommentableType = GraphQL::ObjectType.define do
      interfaces [
        Decidim::Comments::CommentableInterface
      ]
    end
  end
end
