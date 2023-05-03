# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display when a comment has been created.
    class CommentActivityCell < ActivityCell
      include CommentCellsHelper

      def title
        I18n.t("decidim.comments.last_activity.new_comment")
      end

      def participatory_space
        model.participatory_space_lazy
      end

      def comment
        model.resource_lazy
      end
    end
  end
end
