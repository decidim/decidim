# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comments section for a commentable object.
    class CommentsCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :user_signed_in?, to: :controller

      def single_comment_warning
        return unless single_comment?

        render :single_comment_warning
      end

      def blocked_comments_warning
        return unless comments_blocked?
        return unless user_comments_blocked?

        render :blocked_comments_warning
      end

      def user_comments_blocked_warning
        return if comments_blocked? # Shows already the general warning
        return unless user_comments_blocked?

        render :user_comments_blocked_warning
      end

      private

      def comments
        SortedComments.for(model, order_by: default_order)
      end

      def commentable_path(params = {})
        resource_locator(model).path(params)
      end

      def alignment_enabled?
        model.comments_have_alignment?
      end

      def default_order
        "older"
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def node_id
        "comments-for-#{commentable_type.demodulize}-#{model.id}"
      end

      def commentable_type
        model.commentable_type
      end

      def comments_data
        {
          commentableType: commentable_type,
          commentableId: model.id,
          locale: I18n.locale,
          toggleTranslations: machine_translations_toggled?
        }
      end

      def single_comment?
        options[:single_comment] == true
      end

      def machine_translations_toggled?
        options[:machine_translations] == true
      end

      def comments_blocked?
        !model.accepts_new_comments?
      end

      def user_comments_blocked?
        return false unless user_signed_in?

        !model.user_allowed_to_comment?(current_user)
      end
    end
  end
end
