# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root query type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      field :comments do
        description "Lists all commentable's comments."
        type !types[Decidim::Comments::CommentType]

        argument :commentableId, !types.String, "The commentable's ID"
        argument :commentableType, !types.String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`"
        
        resolve ->(_obj, args, _ctx) {
          Decidim::Comments::Comment
            .where(commentable_id: args[:commentableId])
            .where(commentable_type: args[:commentableType])
            .all
        }
      end
    end
  end
end
