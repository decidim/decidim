module Decidim
  module Api
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"

      field :addComment, Decidim::Comments::CommentType do
        description "Add a new comment"
        argument :commentableId, !types.String
        argument :commentableType, !types.String
        argument :body, !types.String

        resolve -> (_obj, args, ctx) {
          Decidim::Comments::Comment.create({
            author: ctx[:current_user],
            commentable_id: args[:commentableId],
            commentable_type: args[:commentableType],
            body: args[:body]
          })
        }
      end
    end
  end
end