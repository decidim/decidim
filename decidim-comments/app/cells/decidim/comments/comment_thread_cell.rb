# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comment thread.
    class CommentThreadCell < Decidim::ViewModel
      def title
        return unless has_threads?

        render :title
      end

      private

      def has_threads?
        model.comment_threads.any?
      end

      def author_name
        return t("decidim.components.comment.deleted_user") if model.author.deleted?

        model.author.name
      end

      def order
        options[:order] || "older"
      end
    end
  end
end
