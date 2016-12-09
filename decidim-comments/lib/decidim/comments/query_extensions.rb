# frozen_string_literal: true
module Decidim
  module Comments
    # This module's job is to extend the API with custom fields related to
    # decidim-comments.
    module QueryExtensions
      # Public: Extends a type with `decidim-comments`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.extend!(type)
        type.define do
          field :comments do
            description "Lists all commentable's comments."
            type !types[CommentType]

            argument :commentableId, !types.String, "The commentable's ID"
            argument :commentableType, !types.String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`"

            resolve ->(_obj, args, _ctx) {
              Comment
                .where(commentable_id: args[:commentableId])
                .where(commentable_type: args[:commentableType])
                .all
            }
          end
        end
      end
    end
  end
end
