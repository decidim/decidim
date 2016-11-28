# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :comments do
        type !types[ CommentType]
        description "Lists all comments."

        resolve -> (_obj, _args, ctx) {
          [
            Decidim::Comments::Comment.new(id: "1", body: "Comment body 1", author: { name: "David Morcillo" }),
            Decidim::Comments::Comment.new(id: "2", body: "Comment body 2", author: { name: "Oriol Gual" })
          ]
        }
      end
    end
  end
end
