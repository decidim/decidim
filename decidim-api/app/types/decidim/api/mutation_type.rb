# frozen_string_literal: true
module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"

      # Every engine should be able to extend the root muation
      # so this code can be included on its own engine
      field :addComment, Decidim::Comments::CommentType do
        description "Add a new comment to a commentable"
        argument :commentableId, !types.String, "The commentable's ID"
        argument :commentableType, !types.String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`"
        argument :body, !types.String, "The comments's body"

        resolve ->(_obj, args, ctx) {
          params = { "comment" => { "body" => args[:body] } }
          commentable = args[:commentableType].constantize.find(args[:commentableId])
          form = Decidim::Comments::CommentForm.from_params(params, author: ctx[:current_user], commentable: commentable)
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
