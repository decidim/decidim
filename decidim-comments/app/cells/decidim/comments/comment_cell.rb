# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a single comment.
    class CommentCell < Decidim::ViewModel
      include Decidim::ResourceHelper
      include Decidim::UserRoleChecker
      include Cell::ViewModel::Partial

      delegate :current_user, :user_signed_in?, to: :controller

      property :root_commentable
      property :created_at
      property :deleted_at
      property :alignment
      property :translated_body
      property :formatted_body
      property :comment_threads
      property :accepts_new_comments?
      property :edited?

      def alignment_badge
        return unless [-1, 1].include?(alignment)

        render :alignment_badge
      end

      def votes
        return unless root_commentable.comments_have_votes?

        render :votes
      end

      def perform_caching?
        super && has_replies_in_children? == false && current_user.blank?
      end

      private

      def parent_element_id
        return unless reply?

        "comment_#{model.decidim_commentable_id}"
      end

      def top_comment_label
        return unless options[:top_comment]

        I18n.t("decidim.components.comments.top_comment_label")
      end

      def comment_label
        if reply?
          t("decidim.components.comment.comment_label_reply", comment_id: model.id, parent_comment_id: model.decidim_commentable_id)
        else
          t("decidim.components.comment.comment_label", comment_id: model.id)
        end
      end

      def reply?
        model.decidim_commentable_type == model.class.name
      end

      def cache_hash
        return @hash if defined?(@hash)

        hash = []
        hash.push(I18n.locale)
        hash.push(model.must_render_translation?(current_organization) ? 1 : 0)
        hash.push(model.authored_by?(current_user) ? 1 : 0)
        hash.push(model.reported_by?(current_user) ? 1 : 0)
        hash.push(model.up_votes_count)
        hash.push(model.down_votes_count)
        hash.push(model.cache_key_with_version)
        hash.push(model.author.cache_key_with_version)
        hash.push(extra_actions.to_s)
        @hash = hash.join(Decidim.cache_key_separator)
      end

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def comment_body
        formatted_body
      end

      def replies
        SortedComments.for(model, order_by: order)
      end

      def order
        options[:order] || "older"
      end

      def extra_actions
        return @extra_actions if defined?(@extra_actions) && @extra_actions.present?

        @extra_actions = model.extra_actions_for(current_user)
        return unless @extra_actions

        @extra_actions.map! do |action|
          [
            "#{icon(action[:icon]) if action[:icon].present?}#{action[:label]}",
            action[:url],
            {
              class: "dropdown__item"
            }
          ].tap do |link|
            link[2][:method] = action[:method] if action[:method].present?
            link[2][:remote] = action[:remote] if action[:remote].present?
            link[2][:data] = action[:data] if action[:data].present?
          end
        end
      end

      def reply_id
        "comment#{model.id}-reply"
      end

      def context_menu_id
        "toggle-context-menu-#{model.id}"
      end

      def can_reply?
        return false if two_columns_layout?
        return false if model.depth >= Comment::MAX_DEPTH
        return true if current_participatory_space && user_has_any_role?(current_user, current_participatory_space)

        user_signed_in? && accepts_new_comments? &&
          root_commentable.user_allowed_to_comment?(current_user)
      end

      def two_columns_layout?
        root_commentable.respond_to?(:two_columns_layout?) && root_commentable.two_columns_layout?
      end

      def author_presenter
        if model.author.respond_to?(:official?) && model.author.official?
          Decidim::Core::OfficialAuthorPresenter.new
        elsif model.user_group
          model.user_group.presenter
        else
          model.author.presenter
        end
      end

      def alignment_badge_classes
        classes = %w(label alignment)
        case alignment
        when 1
          classes << "success"
        when -1
          classes << "alert"
        end
        classes.join(" ")
      end

      def alignment_badge_label
        if alignment == 1
          I18n.t("decidim.components.comment.alignment.in_favor")
        else
          I18n.t("decidim.components.comment.alignment.against")
        end
      end

      def votes_up_classes
        classes = ["button button__sm button__text-secondary js-comment__votes--up"]
        classes << "is-vote-selected" if voted_up?
        classes << "is-vote-notselected" if voted_down?
        classes.join(" ")
      end

      def votes_down_classes
        classes = ["button button__sm button__text-secondary js-comment__votes--down"]
        classes << "is-vote-selected" if voted_down?
        classes << "is-vote-notselected" if voted_up?
        classes.join(" ")
      end

      def commentable_path(params = {})
        if defined?(Decidim::Budgets) && root_commentable.is_a?(Decidim::Budgets::Project)
          resource_locator([root_commentable.budget, root_commentable]).path(params)
        else
          resource_locator(root_commentable).path(params)
        end
      end

      def comment_path
        decidim_comments.comment_path(model)
      end

      def up_votes_count
        model.up_votes_count
      end

      def down_votes_count
        model.down_votes_count
      end

      def root_depth
        options[:root_depth] || 0
      end

      def depth
        model.depth - root_depth
      end

      def reloaded?
        options[:reloaded]
      end

      def voted_up?
        @up_voted ||= model.up_voted_by?(current_user)
      end

      def voted_down?
        @down_voted ||= model.down_voted_by?(current_user)
      end

      def nested?
        depth.positive?
      end

      def nested_level_even?
        depth.even?
      end

      def commentable?
        has_replies? && !model.deleted? && !model.hidden?
      end

      def has_replies?
        model.comment_threads.not_hidden.not_deleted.exists?
      end

      def has_replies_in_children?
        model.descendants.where(decidim_commentable_type: "Decidim::Comments::Comment").not_hidden.not_deleted.exists?
      end

      # action_authorization_button expects current_component to be available
      def current_component
        root_commentable.try(:component)
      end

      def current_participatory_space
        current_component&.participatory_space
      end

      def vote_button_to(path, params, &)
        # actions are linked to objects belonging to a component
        # To apply :comment permission, the modal authorizer should be refactored to allow participatory spaces-level comments
        return button_to(path, params, &) unless current_component

        action_authorized_button_to(:vote_comment, path, params.merge(resource: root_commentable), &)
      end

      def decidim_verifications
        Decidim::Verifications::Engine.routes.url_helpers
      end
    end
  end
end
