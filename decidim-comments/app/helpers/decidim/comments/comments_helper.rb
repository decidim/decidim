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
        session = {
          locale: I18n.locale
        }

        if current_user.present?
          session[:currentUser] = current_user.attributes.slice("id", "name").symbolize_keys
        end

        react_component("Comments", commentableType: resource.class.name, commentableId: resource.id.to_s, session: session)
        + javascript_include_tag("decidim/comments/comments")
      end
    end
  end
end
