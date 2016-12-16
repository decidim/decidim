# frozen_string_literal: true
module Decidim
  module Comments
    # A helper to expose the comments component for a commentable
    module CommentsHelper
      # Creates a Comments component which is rendered using `react_ujs`
      # from react-rails gem
      #
      # resource - A commentable resource
      # options - A hash of options (default: {})
      #           :arguable - A boolean value to indicate if tihs option is available
      #
      # Returns a div which contain a RectComponent to be rendered by `react_ujs`
      def comments_for(resource, options = {})
        commentable_type = resource.class.name
        commentable_id = resource.id.to_s
        react_component("Comments", commentableType: commentable_type,
                                    commentableId: commentable_id,
                                    options: options.slice(:arguable),
                                    locale: I18n.locale) + javascript_include_tag("decidim/comments/comments")
      end
    end
  end
end
