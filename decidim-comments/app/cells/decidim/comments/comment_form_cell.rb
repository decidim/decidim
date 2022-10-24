# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a form for adding a new comment.
    class CommentFormCell < Decidim::ViewModel
      delegate :current_user, :user_signed_in?, to: :controller

      def comment_as_for(form)
        return if verified_user_groups.blank?

        # Note that the form.select does not seem to work correctly in the cell
        # context. The Rails form builder tries to call @template.select which
        # is not available for the cell objects.
        render view: :comment_as, locals: { form: }
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(model.cache_key)
        hash.push(order)
        hash.push(current_user.try(:id))
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

      def form_id
        "new_comment_for_#{commentable_type.demodulize}_#{model.id}"
      end

      def add_comment_id
        "add-comment-#{commentable_type.demodulize}-#{model.id}"
      end

      def comment_as_id
        "add-comment-#{commentable_type.demodulize}-#{model.id}-user-group-id"
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

      def verified_user_groups
        return [] unless current_user

        @verified_user_groups ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      end

      def comment_as_options
        [[current_user.name, ""]] + verified_user_groups.map do |group|
          [group.name, group.id]
        end
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
