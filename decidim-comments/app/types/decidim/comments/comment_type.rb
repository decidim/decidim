# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      field :id, !types.ID, "The Comment's unique ID"

      field :body, !types.String, "The comment message"

      field :createdAt, !types.String, "The creation date of the comment" do
        property :created_at
      end

      field :author, !AuthorType, "The comment's author"

      field :replies, !types[CommentType], "The comment's replies"

      field :canHaveReplies, !types.Boolean, "Define if a comment can or not have replies" do
        property :can_have_replies?
      end

      field :alignment, types.Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'"
    end
  end
end
