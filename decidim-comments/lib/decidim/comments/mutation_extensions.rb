# frozen_string_literal: true
module Decidim
  module Comments
    # This module's job is to extend the API with custom fields related to
    # decidim-comments.
    module MutationExtensions
      # Public: Extends a type with `decidim-comments`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.extend!(type)
        type.define do
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
  end
end
