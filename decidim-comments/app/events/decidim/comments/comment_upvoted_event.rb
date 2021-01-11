# frozen_string_literal: true

module Decidim
  module Comments
    class CommentUpvotedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent

      delegate :author, to: :comment_vote

      private

      def comment_vote
        @comment_vote ||= Decidim::Comments::CommentVote.find_by(decidim_comment_id: extra[:comment_id], decidim_author_id: extra[:author_id])
      end

      def resource_url_params
        { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
