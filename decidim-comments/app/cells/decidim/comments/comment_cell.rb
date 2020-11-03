# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a single comment.
    class CommentCell < Decidim::ViewModel
      include ActionView::Helpers::DateHelper
      include Decidim::IconHelper
      include Decidim::ResourceHelper

      delegate :current_user, :user_signed_in?, to: :controller

      property :root_commentable
      property :created_at
      property :alignment
      property :translated_body
      property :comment_threads
      property :accepts_new_comments?

      def alignment_badge
        return unless [-1, 1].include?(alignment)

        render :alignment_badge
      end

      def votes
        return unless root_commentable.comments_have_votes?

        render :votes
      end

      private

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def comment_body
        Decidim::ContentProcessor.render(translated_body)
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
        if root_commentable.is_a?(Decidim::Budgets::Project)
          resource_locator([root_commentable.budget, root_commentable]).path(params)
        else
          resource_locator(root_commentable).path(params)
        end
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

      def has_replies?
        model.comment_threads.any?
      end
    end
  end
end
