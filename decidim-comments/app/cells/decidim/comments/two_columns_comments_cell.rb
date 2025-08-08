# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to render comments in two columns layout.
    class TwoColumnsCommentsCell < Decidim::Comments::CommentsCell
      def call
        initialize_comments
        @interleaved_comments = interleave_comments(@sorted_comments_in_favor, @sorted_comments_against)
        render :show
      end

      def render_column(top_comment, comments, icon_name, title)
        set_column_variables(top_comment, comments, icon_name, title)
        render :column
      end

      private

      def initialize_comments
        if model.closed?
          load_closed_comments
        else
          @sorted_comments_in_favor = comments_in_favor
          @sorted_comments_against = comments_against
        end
      end

      def load_closed_comments
        @top_comment_in_favor, @sorted_comments_in_favor = sorted_comments(comments_in_favor)
        @top_comment_against, @sorted_comments_against = sorted_comments(comments_against)
      end

      def sorted_comments(comments)
        top_comment = find_top_comment(comments)
        sorted_comments = comments.where.not(id: top_comment&.id).order(created_at: :asc)
        [top_comment, sorted_comments]
      end

      def find_top_comment(comments)
        comments
          .select("*, (up_votes_count - down_votes_count) AS vote_balance, up_votes_count AS upvotes, down_votes_count AS downvotes")
          .where("up_votes_count > 0")
          .reorder("vote_balance DESC, upvotes DESC, downvotes ASC, created_at ASC")
          .first
      end

      def interleave_comments(comments_in_favor, comments_against)
        interleave_top_comments + interleave_remaining_comments(comments_in_favor, comments_against)
      end

      def interleave_top_comments
        return [] unless model.closed?

        Array(@top_comment_in_favor) + Array(@top_comment_against)
      end

      def interleave_remaining_comments(comments_in_favor, comments_against)
        interleaved = []
        max_length = [comments_in_favor.size, comments_against.size].max

        max_length.times do |i|
          interleaved << comments_in_favor[i] if comments_in_favor[i]
          interleaved << comments_against[i] if comments_against[i]
        end

        interleaved
      end

      def comments_in_favor
        @comments_in_favor ||= model.comments.positive.order(:created_at)
      end

      def comments_against
        @comments_against ||= model.comments.negative.order(:created_at)
      end

      def set_column_variables(top_comment, comments, icon_name, title)
        @top_comment = top_comment
        @comments = comments
        @icon_name = icon_name
        @title = title
      end
    end
  end
end
