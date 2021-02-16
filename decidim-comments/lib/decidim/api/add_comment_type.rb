# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a mutation to create new comments.
    class AddCommentType < Decidim::Api::Types::BaseObject
      graphql_name "Add comment"
      description "Add a new comment"

      field :comment, Decidim::Comments::CommentType, null: true, description: "The new created comment"
    end
  end
end
