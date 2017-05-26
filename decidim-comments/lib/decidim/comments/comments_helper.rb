# frozen_string_literal: true

module Decidim
  module Comments
    # A helper to expose the comments component for a commentable
    module CommentsHelper
      # Render commentable comments inside the `expanded` template content.
      #
      # resource - A commentable resource
      def comments_for(resource)
        return unless resource.commentable?
        content_for :expanded do
          inline_comments_for(resource)
        end
      end

      # Creates a Comments component which is rendered using `ReactDOM`
      #
      # resource - A commentable resource
      #
      # Returns a div which contain a RectComponent
      def inline_comments_for(resource)
        return unless resource.commentable?
        commentable_type = resource.commentable_type
        commentable_id = resource.id.to_s
        node_id = "comments-for-#{commentable_type.demodulize}-#{commentable_id}"
        react_comments_component(node_id, commentableType: commentable_type,
                                          commentableId: commentable_id,
                                          locale: I18n.locale)
      end

      # Private: Render Comments component using inline javascript
      #
      # node_id - The id of the DOMElement to render the React component
      # props   - A hash corresponding to Comments component props
      def react_comments_component(node_id, props)
        content_tag("div", "", id: node_id) +
          javascript_include_tag("decidim/comments/comments") +
          javascript_tag(%{
            window.DecidimComments.renderCommentsComponent(
              '#{node_id}',
              {
                commentableType: "#{props[:commentableType]}",
                commentableId: "#{props[:commentableId]}",
                locale: "#{props[:locale]}"
              }
            );
          })
      end
    end
  end
end
