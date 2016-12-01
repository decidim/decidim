# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :comments do
        description "Lists all comments."
        type !types[Decidim::Comments::CommentType]
        argument :commentableId, !types.String
        argument :commentableType, !types.String

        resolve -> (_obj, args, ctx) {
          Decidim::Comments::Comment
            .where(commentable_id: args[:commentableId])
            .where(commentable_type: args[:commentableType])
            .all
        }
      end
    end
  end
end
