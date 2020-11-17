# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a commentable object.
    class CommentableType < GraphQL::Schema::Object
      graphql_name "Commentable"
      description "A commentable object"

      implements Decidim::Comments::CommentableInterface
    end
  end
end
