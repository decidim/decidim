# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to render comments in two columns layout.
    class TwoColumnsCommentsCell < Decidim::Comments::CommentsCell
      def call
        initialize_comments
        render :show
      end

      def render_column(top_comment, comments, icon_name, title, alignment, has_more)
        set_column_variables(top_comment, comments, icon_name, title, alignment, has_more)
        render :column
      end

      private

      def initialize_comments
        if model.closed?
          load_closed_comments
        else
          @sorted_comments_in_favor = comments_in_favor_query.query
          @sorted_comments_against = comments_against_query.query
        end

        @has_more_in_favor = comments_in_favor_query.has_more?
        @has_more_against = comments_against_query.has_more?

        load_mobile_comments
      end

      def load_closed_comments
        @top_comment_in_favor, @sorted_comments_in_favor = sorted_comments(comments_in_favor_query.query)
        @top_comment_against, @sorted_comments_against = sorted_comments(comments_against_query.query)
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

      def comments_in_favor_query
        @comments_in_favor_query ||= SortedComments.new(model, order_by: order, alignment: 1, offset: 0)
      end

      def comments_against_query
        @comments_against_query ||= SortedComments.new(model, order_by: order, alignment: -1, offset: 0)
      end

      def load_mobile_comments
        @sorted_comments_query = SortedComments.new(model, order_by: order, offset: 0)
        @mobile_comments = @sorted_comments_query.query
        @has_more_mobile = @sorted_comments_query.has_more?
      end

      def set_column_variables(top_comment, comments, icon_name, title, alignment, has_more)
        @top_comment = top_comment
        @comments = comments
        @icon_name = icon_name
        @title = title
        @alignment = alignment
        @has_more = has_more
      end
    end
  end
end
