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
        node_id = "comments-for-#{commentable_type.demodulize}-#{commentable_id}"

        react_comments_component(node_id, {
          commentableType: commentable_type,
          commentableId: commentable_id,
          options: options.slice(:arguable),
          locale: I18n.locale
        })
      end
      
      # Private: Render Comments component using inline javascript
      #
      # node_id - The id of the DOMElement to render the React component
      # props   - A hash corresponding to Comments component props
      def react_comments_component(node_id, props)
        content_tag('div', '', id: node_id) +
        javascript_tag(%{
          $.getScript('#{asset_path('decidim/comments/comments')}')
            .then(function () {
              window.DecidimComments.renderCommentsComponent(
                '#{node_id}',
                {
                  commentableType: "#{props[:commentableType]}",
                  commentableId: "#{props[:commentableId]}",
                  options: JSON.parse("#{j(props[:options].to_json)}"),
                  locale: "#{props[:locale]}"
                }
              );
            });
        })
      end
    end
  end
end
