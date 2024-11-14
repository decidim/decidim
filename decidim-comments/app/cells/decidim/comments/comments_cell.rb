# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comments section for a commentable object.
    class CommentsCell < Decidim::ViewModel
      include UserRoleChecker
      delegate :user_signed_in?, to: :controller

      def render_comments
        if single_comment?
          render_single_comment
        elsif supports_two_columns_layout?
          render_comments_in_two_columns
        else
          render :comments_in_single_column
        end
      end

      def interleave_comments(comments_in_favor, comments_against)
        result = []
        max_length = [comments_in_favor.size, comments_against.size].max.to_i

        max_length.times do |i|
          result << comments_in_favor[i] if comments_in_favor[i]
          result << comments_against[i] if comments_against[i]
        end

        result
      end

      def render_column(top_comment, comments, icon_name, title)
        @top_comment = top_comment
        @comments = comments
        @icon_name = icon_name
        @title = title

        render :column
      end

      def comments_in_favor
        @comments_in_favor ||= model.comments.positive.order(created_at: :asc)
      end

      def comments_against
        @comments_against ||= model.comments.negative.order(created_at: :asc)
      end

      def add_comment
        render :add_comment if can_add_comments?
      end

      def single_comment_warning
        return unless single_comment?

        render :single_comment_warning
      end

      def comments_loading
        return if single_comment?

        render :comments_loading
      end

      def blocked_comments_warning
        return unless comments_blocked?
        return if user_comments_blocked?

        render :blocked_comments_warning
      end

      def user_comments_blocked_warning
        return if comments_blocked? # Shows already the general warning
        return unless user_comments_blocked?

        render :user_comments_blocked_warning
      end

      private

      def supports_two_columns_layout?
        model.respond_to?(:comments_layout) && model.two_columns_layout?
      end

      def render_single_comment
        @sorted_comments_in_favor = [single_comment]
        render :comments_in_single_column
      end

      def render_comments_in_two_columns
        if model.closed?
          assign_top_comments

          @sorted_comments_in_favor = sorted_comments_without_top(@top_comment_in_favor, comments_in_favor)
          @sorted_comments_against = sorted_comments_without_top(@top_comment_against, comments_against)
        else
          @sorted_comments_in_favor = comments_in_favor
          @sorted_comments_against = comments_against
        end

        @interleaved_comments = interleave_comments(@sorted_comments_in_favor, @sorted_comments_against)

        render :comments_in_two_columns
      end

      def assign_top_comments
        @top_comment_in_favor = top_comment(comments_in_favor)
        @top_comment_against = top_comment(comments_against)
      end

      def top_comment(comments)
        comments.reorder(up_votes_count: :desc).where("up_votes_count > 0").first
      end

      def sorted_comments_without_top(top_comment, comments)
        return comments unless model.closed?

        comments.where.not(id: top_comment&.id).order(created_at: :asc)
      end

      def can_add_comments?
        return true if current_participatory_space && user_has_any_role?(current_user, current_participatory_space)
        return if single_comment?
        return if comments_blocked?
        return if user_comments_blocked?

        true
      end

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def comments
        single_comment? ? [single_comment] : []
      end

      def comments_count
        model.comments_count
      end

      def root_depth
        return 0 unless single_comment?

        single_comment.depth
      end

      def commentable_path(params = {})
        return resource_locator(Array(options[:polymorphic]).push(model)).path(params) if options[:polymorphic]

        resource_locator(model).path(params)
      end

      def alignment_enabled?
        model.comments_have_alignment?
      end

      def available_orders
        %w(best_rated recent older most_discussed)
      end

      def order
        options[:order] || "older"
      end

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def node_id
        "comments-for-#{commentable_type.demodulize}-#{model.id}"
      end

      def threads_node_id
        "#{node_id}-threads"
      end

      def commentable_type
        model.commentable_type
      end

      def comments_data
        {
          singleComment: single_comment?,
          toggleTranslations: machine_translations_toggled?,
          commentableGid: model.to_signed_global_id.to_s,
          commentsUrl: decidim_comments.comments_path,
          rootDepth: root_depth,
          order:
        }
      end

      def single_comment?
        single_comment.present?
      end

      def single_comment
        return if options[:single_comment].blank?

        @single_comment ||= SortedComments.for(model, id: options[:single_comment], order_by: order).first
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

      def comment_permissions?
        [model, current_component].any? do |resource|
          resource.try(:permissions).try(:[], "comment")
        end
      end

      # action_authorization_link expects current_component to be available
      def current_component
        model.try(:component)
      end

      def current_participatory_space
        model.try(:participatory_space)
      end

      def blocked_comments_for_unauthorized_user_warning_link
        options = if current_component.present?
                    { resource: model }
                  else
                    { resource: model, permissions_holder: model }
                  end
        action_authorized_link_to(:comment, commentable_path, options) do
          t("decidim.components.comments.blocked_comments_for_unauthorized_user_warning")
        end
      end
    end
  end
end
