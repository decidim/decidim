# frozen_string_literal: true

module Decidim
  module Comments
    class CommentVotedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent

      i18n_attributes :upvotes
      i18n_attributes :downvotes

      def upvotes
        extra[:upvotes]
      end

      def downvotes
        extra[:downvotes]
      end

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
