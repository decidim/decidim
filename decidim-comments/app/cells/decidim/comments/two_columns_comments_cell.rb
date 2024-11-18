# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to render comments in two columns layout.
    class TwoColumnsCommentsCell < Decidim::ViewModel
      def call
        if model.closed?
          assign_top_comments

          @sorted_comments_in_favor = sorted_comments_without_top(@top_comment_in_favor, comments_in_favor)
          @sorted_comments_against = sorted_comments_without_top(@top_comment_against, comments_against)
        else
          @sorted_comments_in_favor = comments_in_favor
          @sorted_comments_against = comments_against
        end

        @interleaved_comments = interleave_comments(@sorted_comments_in_favor, @sorted_comments_against)

        render :show
      end

      def render_column(top_comment, comments, icon_name, title)
        @top_comment = top_comment
        @comments = comments
        @icon_name = icon_name
        @title = title

        render :column
      end

      private

      def assign_top_comments
        @top_comment_in_favor = top_comment(comments_in_favor)
        @top_comment_against = top_comment(comments_against)
      end

      def top_comment(comments)
        comments.reorder(up_votes_count: :desc).where("up_votes_count > 0").first
      end

      def sorted_comments_without_top(top_comment, comments)
        return comments unless model.closed?

        comments.where.not(id: top_comment&.id).order(created_at: :asc)
      end

      def interleave_comments(comments_in_favor, comments_against)
        result = []
        max_length = [comments_in_favor.size, comments_against.size].max.to_i

        max_length.times do |i|
          result << comments_in_favor[i] if comments_in_favor[i]
          result << comments_against[i] if comments_against[i]
        end

        result
      end

      def comments_in_favor
        @comments_in_favor ||= model.comments.positive.order(created_at: :asc)
      end

      def comments_against
        @comments_against ||= model.comments.negative.order(created_at: :asc)
      end
    end
  end
end
