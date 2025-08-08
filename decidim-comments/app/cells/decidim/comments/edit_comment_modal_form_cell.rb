# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a form for editing a comment.
    class EditCommentModalFormCell < Decidim::ViewModel
      alias comment model

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(model.cache_key_with_version)
        hash.push(current_user.try(:id))
        hash.join(Decidim.cache_key_separator)
      end

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def form_id
        "edit_comment_#{comment.id}"
      end

      def form_object
        Decidim::Comments::CommentForm.new(
          body: comment.translated_body
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
        return unless organization

        organization.comments_max_length if organization.comments_max_length.positive?
      end

      def organization
        return model.organization if model.respond_to?(:organization)

        model.component.organization if model.component.organization.comments_max_length.positive?
      end
    end
  end
end
