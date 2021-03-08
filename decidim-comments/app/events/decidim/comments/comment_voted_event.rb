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

      def resource_url_params
        { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
