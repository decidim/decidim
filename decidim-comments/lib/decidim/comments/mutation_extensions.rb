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
            argument :alignment, types.Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", default_value: 0

            resolve lambda { |_obj, args, ctx|
              params = { "comment" => { "body" => args[:body], "alignment" => args[:alignment] } }
              form = Decidim::Comments::CommentForm.from_params(params)
              commentable = args[:commentableType].constantize.find(args[:commentableId])
              Decidim::Comments::CreateComment.call(form, ctx[:current_user], commentable) do
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
