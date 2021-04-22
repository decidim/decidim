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

      def resource
        target_resource(@resource)
      end

      def target_resource(t_resource)
        t_resource.is_a?(Decidim::Comments::Comment) ? target_resource(t_resource.commentable) : t_resource
      end
    end
  end
end
