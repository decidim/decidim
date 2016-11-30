# frozen_string_literal: true
module Decidim
  module Api
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      field :id, !types.ID, "The Comment's unique ID"

      field :body, !types.String, "The comment message"

      field :createdAt, !types.String, "The comment created at"

      field :author do
        type !AuthorType

        resolve -> (obj, _args, ctx) do
          obj.author
        end
      end
    end

    AuthorType = GraphQL::ObjectType.define do
      name "Author"
      description "An author"

      field :name, !types.String
    end
  end
end