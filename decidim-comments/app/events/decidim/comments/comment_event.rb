# frozen-string_literal: true

module Decidim
  module Comments
    # This module is used to be included in events triggered by comments.
    #
    module CommentEvent
      extend ActiveSupport::Concern
      include Decidim::Events::AuthorEvent

      included do
        delegate :author, to: :comment

        def resource_path
          resource_locator.path(url_params)
        end

        def resource_url
          resource_locator.url(url_params)
        end

        def resource_text
          comment.formatted_body
        end

        private

        def comment
          @comment ||= Decidim::Comments::Comment.find(extra[:comment_id])
        end

        def url_params
          { anchor: "comment_#{comment.id}" }
        end
      end
    end
  end
end
