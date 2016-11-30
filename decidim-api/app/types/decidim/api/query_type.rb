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
            Decidim::Comments::Comment.new(id: "1", body: "Comment body 1", createdAt: (Time.zone.now - 1.hour).to_s, author: { name: "David Morcillo" }),
            Decidim::Comments::Comment.new(id: "2", body: "Comment body 2", createdAt: (Time.zone.now - 2.hour).to_s, author: { name: "Oriol Gual" })
          ]
        }
      end
    end
  end
end
