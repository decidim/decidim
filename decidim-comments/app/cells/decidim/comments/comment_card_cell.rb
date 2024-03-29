# frozen_string_literal: true

module Decidim
  module Comments
    # This cell renders the comment card for an instance of a Comment
    # the default size is the Search Card (:s)
    class CommentCardCell < Decidim::ViewModel
      include CommentCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/comments/comment_s"
      end
    end
  end
end
