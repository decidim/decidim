# frozen_string_literal: true
# TODO: just for testing purposes
$comments = [
  Decidim::Comments::Comment.new(id: "1", body: "Comment body 1", createdAt: (Time.zone.now - 1.hour).to_s, author: { name: "David Morcillo" }),
  Decidim::Comments::Comment.new(id: "2", body: "Comment body 2", createdAt: (Time.zone.now - 2.hour).to_s, author: { name: "Oriol Gual" }),
  Decidim::Comments::Comment.new(id: "3", body: "Comment body 3", createdAt: (Time.zone.now - 3.hour).to_s, author: { name: "Marc Riera" })
]
module Decidim
  module Api
    # This type represents the root type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :comments do
        type !types[CommentType]
        description "Lists all comments."

        resolve -> (_obj, _args, ctx) {
          $comments
        }
      end
    end
  end
end
