module Decidim
  module Api
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"

      field :addComment, CommentType do
        argument :body, !types.String
        description "Add a new comment"

        resolve -> (_obj, args, ctx) {
          new_comment = Decidim::Comments::Comment.new(id: SecureRandom.uuid, body: args[:body], createdAt: Time.now.to_s, author: { name: ctx[:current_user].name })
          $comments << new_comment
          new_comment
        }
      end
    end
  end
end