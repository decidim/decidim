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
        description "The comment created at"
        property :created_at
      end

      field :author do
        type !AuthorType

        resolve ->(obj, _args, _ctx) do
          obj.author
        end
      end
    end
  end
end
