module Decidim
  module Api
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"

      field :addComment, Decidim::Comments::CommentType do
        description "Add a new comment"
        argument :body, !types.String

        resolve -> (_obj, args, ctx) {
          Decidim::Comments::Comment.create(body: args[:body], author: ctx[:current_user])
        }
      end
    end
  end
end