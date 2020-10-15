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
        react_comments_component(
          node_id, commentableType: commentable_type,
                   commentableId: commentable_id,
                   locale: I18n.locale,
                   toggleTranslations: machine_translations_toggled?,
                   commentsMaxLength: comments_max_length(resource)
        )
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
                locale: "#{props[:locale]}",
                toggleTranslations: #{props[:toggleTranslations]},
                commentsMaxLength: "#{props[:commentsMaxLength]}"
              }
            );
          })
      end

      def comments_max_length(resource)
        return 1000 unless resource.respond_to?(:component)
        return component_comments_max_length(resource) if component_comments_max_length(resource)
        return organization_comments_max_length(resource) if organization_comments_max_length(resource)

        1000
      end

      def component_comments_max_length(resource)
        return unless resource.component&.settings.respond_to?(:comments_max_length)

        resource.component.settings.comments_max_length if resource.component.settings.comments_max_length.positive?
      end

      def organization_comments_max_length(resource)
        resource.component.organization.comments_max_length if resource.component.organization.comments_max_length.positive?
      end
    end
  end
end
