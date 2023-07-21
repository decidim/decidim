# frozen_string_literal: true

module Decidim
  module Comments
    # This cell renders the comment card for an instance of a Comment
    # the default size is the Medium Card (:m)
    class CommentCardCell < Decidim::ViewModel
      include CommentCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      # REDESIGN_PENDING: size :m is deprecated
      def card_size
        case @options[:size]
        when :s
          "decidim/comments/comment_s"
        else
          "decidim/comments/comment_m"
        end
      end
    end
  end
end
