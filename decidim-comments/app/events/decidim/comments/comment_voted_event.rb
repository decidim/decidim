# frozen_string_literal: true

module Decidim
  module Comments
    class CommentVotedEvent < Decidim::Events::SimpleEvent
      include Decidim::Comments::CommentEvent

      i18n_attributes :upvotes
      i18n_attributes :downvotes

      def initialize(resource:, event_name:, user:, user_role: nil, extra: nil)
        resource = target_resource(resource)
        super
      end

      def upvotes
        extra[:upvotes]
      end

      def downvotes
        extra[:downvotes]
      end

      def perform_translation?
        false
      end

      private

      def resource_url_params
        { anchor: "comment_#{comment.id}" }
      end

      def target_resource(t_resource)
        t_resource.is_a?(Decidim::Comments::Comment) ? t_resource.root_commentable : t_resource
      end
    end
  end
end
