# frozen_string_literal: true

module Decidim
  module Comments
    module CommentList
      class Component < Decidim::BaseComponent
        def initialize(commentable, options = {})
          @commentable = commentable
          @options = options.with_defaults(order: "older")
        end

        private

        include Decidim::ResourceHelper
        attr_reader :commentable, :options

        delegate :commentable_type, :comments_count, to: :commentable
        delegate :decidim_comments, :user_signed_in?, to: :helpers

        # private
        # include Decidim::IconHelper
        #
        # delegate :user_signed_in?, to: :controller
        #
        def add_comment
          return if single_comment?
          return if comments_blocked?
          return if user_comments_blocked?

          helpers.render Decidim::Comments::AddComment::Component.new(commentable, root_depth)
        end

        def single_comment_warning
          return unless single_comment?

          announcement({
                         title: t("decidim.components.comments.single_comment_warning_title"),
                         body: t("decidim.components.comments.single_comment_warning_html", url: "#{commentable_path}##{node_id}")
                       },
                       callout_class: "secondary",
                       raw: true)
        end

        def comments_loading
          return if single_comment?

          announcement(t("decidim.components.comments.loading"), callout_class: "primary loading-comments mb-4")
        end

        def blocked_comments_warning
          return unless comments_blocked?
          return unless user_comments_blocked?

          announcement(t("decidim.components.comments.blocked_comments_warning"), callout_class: "warning")
        end

        def user_comments_blocked_warning
          return if comments_blocked? # Shows already the general warning
          return unless user_comments_blocked?

          announcement(comment_permissions? ? blocked_comments_for_unauthorized_user_warning_link : t("decidim.components.comments.blocked_comments_for_user_warning"), raw: true)
        end

        #
        # private
        #
        # def decidim_comments
        #   Decidim::Comments::Engine.routes.url_helpers
        # end
        #
        def comments
          single_comment? ? [single_comment] : []
        end
        #
        # def comments_count
        #   model.comments_count
        # end

        def root_depth
          return 0 unless single_comment?

          single_comment.depth
        end

        def commentable_path(params = {})
          return resource_locator(Array(options[:polymorphic]).push(commentable)).path(params) if options[:polymorphic]

          resource_locator(commentable).path(params)
        end
        #
        # def alignment_enabled?
        #   model.comments_have_alignment?
        # end
        #
        # def available_orders
        #   %w(best_rated recent older most_discussed)
        # end

        def order
          options[:order] || "older"
        end

        #
        # def decidim
        #   Decidim::Core::Engine.routes.url_helpers
        # end
        #
        def node_id
          "comments-for-#{commentable_type.demodulize}-#{commentable.id}"
        end

        #
        # def commentable_type
        #   model.commentable_type
        # end
        #
        def comments_data
          {
            singleComment: single_comment?,
            toggleTranslations: machine_translations_toggled?,
            commentableGid: commentable.to_signed_global_id.to_s,
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

          @single_comment ||= SortedComments.for(commentable, id: options[:single_comment], order_by: order).first
        end

        def machine_translations_toggled?
          options[:machine_translations] == true
        end

        def comments_blocked?
          !commentable.accepts_new_comments?
        end

        def user_comments_blocked?
          return false unless user_signed_in?

          !commentable.user_allowed_to_comment?(current_user)
        end
        #
        # def comment_permissions?
        #   [model, current_component].any? do |resource|
        #     resource.try(:permissions).try(:[], "comment")
        #   end
        # end
        #
        # # action_authorization_link expects current_component to be available
        # def current_component
        #   model.try(:component)
        # end
        #
        # def blocked_comments_for_unauthorized_user_warning_link
        #   options = if current_component.present?
        #               { resource: model }
        #             else
        #               { resource: model, permissions_holder: model }
        #             end
        #   action_authorized_link_to(:comment, commentable_path, options) do
        #     t("decidim.components.comments.blocked_comments_for_unauthorized_user_warning")
        #   end
        # end

        def comments_are_loading_warning
          announcement(t("decidim.components.comments.loading"), callout_class: "primary loading-comments hidden")
        end

        def order_control
          helpers.render OrderControl::Component.new(commentable, options)
        end

        def announcement(announcement, options = {})
          helpers.render Decidim::AnnouncementComponent.new(announcement, options)
        end
      end
    end
  end
end
