# frozen-string_literal: true

module Decidim
  module Comments
    # This module is used to be included in events triggered by comments.
    #
    module CommentEvent
      extend ActiveSupport::Concern
      include Decidim::Events::AuthorEvent

      included do
        def resource_text
          comment.formatted_body
        end

        def author
          comment.normalized_author
        end

        def author_presenter
          return unless author

          @author_presenter ||= case author
                                when Decidim::User
                                  Decidim::UserPresenter.new(author)
                                when Decidim::UserGroup
                                  Decidim::UserGroupPresenter.new(author)
                                end
        end

        private

        def comment
          @comment ||= Decidim::Comments::Comment.find(extra[:comment_id])
        end

        def resource_url_params
          { anchor: "comment_#{comment.id}" }
        end
      end
    end
  end
end
