# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      field :id, !types.ID, "The Comment's unique ID"

      field :body, !types.String, "The comment message"

      field :createdAt do
        type !types.String
        description "The creation date of the comment"
        property :created_at
      end

      field :author, !AuthorType, "The comment's author" do
        resolve ->(obj, _args, _ctx) { obj.author }
      end

      field :replies, !types[CommentType], "The comment's replies" do
        resolve ->(obj, _args, _ctx) { obj.replies }
      end
    end
  end
end
