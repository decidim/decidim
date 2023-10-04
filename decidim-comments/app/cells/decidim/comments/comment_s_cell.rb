# frozen_string_literal: true

module Decidim
  module Comments
    # This cell renders the Search (:s) comment card
    # for a given instance of a Comment
    class CommentSCell < Decidim::CardSCell
      include CommentCellsHelper

      alias comment model

      private

      def title
        resource_link_text
      end

      def resource_path
        resource_link_path
      end

      def metadata_cell
        "decidim/comments/comment_metadata"
      end
    end
  end
end
