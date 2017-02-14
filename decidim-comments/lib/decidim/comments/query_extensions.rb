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
          field :commentable do
            type !CommentableType

            argument :id, !types.String, "The commentable's ID"
            argument :type, !types.String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`"

            resolve lambda { |_obj, args, _ctx|
              args[:type].constantize.find(args[:id])
            }
          end
        end
      end
    end
  end
end
