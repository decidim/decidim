# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a form for adding a new comment.
    class CommentFormCell < Decidim::ViewModel
      def comment_as
        return if current_user.blank?

        render
      end

      def two_columns_layout?
        model.respond_to?(:two_columns_layout?) && model.two_columns_layout?
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(model.cache_key)
        hash.push(order)
        hash.push(current_user.try(:id))
        hash.push(options)
        hash.join(Decidim.cache_key_separator)
      end

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def order
        options[:order] || "older"
      end

      def commentable_type
        model.commentable_type
      end

      def reply?
        model.is_a?(Decidim::Comments::Comment)
      end

      def alignment_enabled?
        model.comments_have_alignment?
      end

      def form_id
        "new_comment_for_#{commentable_type.demodulize}_#{model.id}"
      end

      def add_comment_id
        "add-comment-#{commentable_type.demodulize}-#{model.id}"
      end

      def root_depth
        options[:root_depth] || 0
      end

      def form_object
        Decidim::Comments::CommentForm.new(
          commentable_gid: model.to_signed_global_id.to_s,
          alignment: 0
        )
      end

      def author_presenter
        current_user&.presenter
      end

      def comments_max_length
        return 1000 unless model.respond_to?(:component)
        return component_comments_max_length if component_comments_max_length
        return organization_comments_max_length if organization_comments_max_length

        1000
      end

      def component_comments_max_length
        return unless model.component&.settings.respond_to?(:comments_max_length)

        model.component.settings.comments_max_length if model.component.settings.comments_max_length.to_i.positive?
      end

      def organization_comments_max_length
        return unless organization

        organization.comments_max_length if organization.comments_max_length.to_i.positive?
      end

      def organization
        return model.organization if model.respond_to?(:organization)

        model.component.organization if model.component.organization.comments_max_length.positive?
      end
    end
  end
end
