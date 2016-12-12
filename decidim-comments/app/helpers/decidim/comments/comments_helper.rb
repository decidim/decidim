# frozen_string_literal: true
module Decidim
  module Comments
    # A helper to expose the comments component for a commentable
    module CommentsHelper
      # Creates a Comments component which is rendered using `react_ujs`
      # from react-rails gem
      #
      # resource - A commentable resource
      #
      # Returns a div which contain a RectComponent to be rendered by `react_ujs`
      def comments_for(resource)
        react_component("Comments", commentableType: resource.class.name, commentableId: resource.id.to_s, locale: I18n.locale) + javascript_include_tag("decidim/comments/comments")
      end
    end
  end
end
