# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a single comment.
    class CommentCell < Decidim::ViewModel
      include ActionView::Helpers::DateHelper
      include Decidim::IconHelper
      include Decidim::ResourceHelper
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

      def cache_hash
        return @hash if defined?(@hash)

        hash = []
        hash.push(I18n.locale)
        hash.push(model.must_render_translation?(current_organization) ? 1 : 0)
        hash.push(model.authored_by?(current_user) ? 1 : 0)
        hash.push(model.reported_by?(current_user) ? 1 : 0)
        hash.push(model.cache_key_with_version)
        hash.push(model.author.cache_key_with_version)
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

      def reply_id
        "comment#{model.id}-reply"
      end

      def context_menu_id
        "toggle-context-menu-#{model.id}"
      end

      def can_reply?
        user_signed_in? && accepts_new_comments? &&
          root_commentable.user_allowed_to_comment?(current_user)
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

      def comment_classes
        classes = ["comment"]
        if nested?
          classes << "comment--nested"
          classes << "comment--nested--alt" if nested_level_even?
        end
        classes.join(" ")
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
        classes = ["comment__votes--up"]
        classes << "is-vote-selected" if voted_up?
        classes << "is-vote-notselected" if voted_down?
        classes.join(" ")
      end

      def votes_down_classes
        classes = ["comment__votes--down"]
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
        model.up_votes.count
      end

      def down_votes_count
        model.down_votes.count
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
        model.up_voted_by?(current_user)
      end

      def voted_down?
        model.down_voted_by?(current_user)
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

      def vote_button_to(path, params, &)
        # actions are linked to objects belonging to a component
        # In consultations, a question belong to a participatory_space but it has comments
        # To apply :comment permission, the modal authorizer should be refactored to allow participatory spaces-level comments
        return button_to(path, params, &) unless current_component

        action_authorized_button_to(:vote_comment, path, params.merge(resource: root_commentable), &)
      end
    end
  end
end
