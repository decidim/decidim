# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a form for adding a new comment.
    class CommentFormCell < Decidim::ViewModel
      delegate :user_signed_in?, to: :controller

      private

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def commentable_type
        model.commentable_type
      end

      def add_comment_id
        "add-comment-#{commentable_type.demodulize}-#{model.id}"
      end

      def form_object
        Decidim::Comments::CommentForm.new(
          commentable_gid: model.to_signed_global_id.to_s
        )
      end

      def comments_max_length
        return 1000 unless model.respond_to?(:component)
        return component_comments_max_length if component_comments_max_length
        return organization_comments_max_length if organization_comments_max_length

        1000
      end

      def component_comments_max_length
        return unless model.component&.settings.respond_to?(:comments_max_length)

        model.component.settings.comments_max_length if model.component.settings.comments_max_length.positive?
      end

      def organization_comments_max_length
        model.component.organization.comments_max_length if model.component.organization.comments_max_length.positive?
      end
    end
  end
end
