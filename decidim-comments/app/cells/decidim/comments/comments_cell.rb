# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comments section for a commentable object.
    class CommentsCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :user_signed_in?, to: :controller

      property :comments

      private

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def node_id
        "comments-for-#{commentable_type.demodulize}-#{model.id}"
      end

      def add_comment_id
        "add-comment-#{commentable_type.demodulize}-#{model.id}"
      end

      def comment_form
        Decidim::Comments::CommentForm.new(commentable: model)
      end

      def commentable_type
        model.commentable_type
      end

      def comments_data
        {
          commentableType: commentable_type,
          commentableId: model.id,
          locale: I18n.locale,
          toggleTranslations: machine_translations_toggled?,
          commentsMaxLength: comments_max_length
        }
      end

      def machine_translations_toggled?
        options[:machine_translations] == true
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
