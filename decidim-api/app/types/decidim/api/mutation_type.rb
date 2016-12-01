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
          commentable = args[:commentableType].constantize.find(args[:commentableId])
          form = Decidim::Comments::CommentForm.from_params({
            "comment" => {
              "body" => args[:body]
            }
          }, author: ctx[:current_user], commentable: commentable)

          Decidim::Comments::CreateComment.call(form) do
            on(:ok) do |comment|
              return comment
            end
          end
        }
      end
    end
  end
end