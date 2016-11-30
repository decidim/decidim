# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :comments do
        type !types[Decidim::Comments::CommentType]
        description "Lists all comments."

        resolve -> (_obj, _args, ctx) {
          Decidim::Comments::Comment.all
        }
      end
    end
  end
end
