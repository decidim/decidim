# frozen_string_literal: true

module Decidim
  module Comments
    # This cell renders the Medium (:m) comment card
    # for an given instance of a Comment
    class CommentMCell < Decidim::CardMCell
      include CommentCellsHelper

      def statuses
        []
      end

      def comment
        model
      end

      def has_header?
        false
      end

      delegate :participatory_space, to: :model

      def description
        strip_tags(model.formatted_body).truncate(200, separator: /\s/)
      end
    end
  end
end
