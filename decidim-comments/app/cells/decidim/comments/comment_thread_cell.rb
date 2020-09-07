# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comment thread.
    class CommentThreadCell < Decidim::ViewModel
      def title
        return unless has_threads?

        render
      end

      private

      def has_threads?
        obj.comment_threads.size.positive?
      end

      def author_name
        return t("components.comment.deleted_user") if model.author.deleted

        model.author.name
      end
    end
  end
end
