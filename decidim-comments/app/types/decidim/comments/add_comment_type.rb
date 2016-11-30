module Decidim
  module Comments
    AddCommentType = GraphQL::ObjectType.define do
      name "Add comment"
      description "Add a new comment"

      field :comment, CommentType, "The new comment created"
    end
  end
end