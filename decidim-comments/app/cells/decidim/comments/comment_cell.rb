# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a single comment.
    class CommentCell < Decidim::ViewModel
      include ActionView::Helpers::DateHelper
      include Decidim::IconHelper
      include Decidim::ResourceHelper

      delegate :user_signed_in?, to: :controller

      property :commentable
      property :created_at
      property :translated_body

      private

      def reply_id
        "comment#{model.id}-reply"
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
        classes << "comment--nested" if nested?
        classes.join(" ")
      end

      def commentable_path(params = {})
        resource_locator(commentable).path(params)
      end

      def up_votes_count
        model.up_votes.count
      end

      def down_votes_count
        model.down_votes.count
      end

      def nested?
        model.depth.positive?
      end

      def has_replies?
        model.comments.any?
      end
    end
  end
end
