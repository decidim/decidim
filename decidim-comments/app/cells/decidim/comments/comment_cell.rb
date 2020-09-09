# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a single comment.
    class CommentCell < Decidim::ViewModel
      include ActionView::Helpers::DateHelper
      include Decidim::IconHelper
      include Decidim::ResourceHelper

      delegate :user_signed_in?, to: :controller

      property :root_commentable
      property :created_at
      property :translated_body
      property :comment_threads
      property :accepts_new_comments?

      private

      def replies
        SortedComments.for(model, order_by: default_order)
      end

      def default_order
        "older"
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

      def commentable_path(params = {})
        resource_locator(root_commentable).path(params)
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
