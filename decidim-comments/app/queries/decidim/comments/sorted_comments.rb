# frozen_string_literal: true

module Decidim
  module Comments
    # A class used to find comments for a commentable resource
    class SortedComments < Decidim::Query
      # Default number of comments to load at once
      DEFAULT_COMMENTS_LIMIT = 20
      # Default number of replies to load at once
      DEFAULT_REPLIES_LIMIT = 10

      attr_reader :commentable

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # commentable - a resource that can have comments
      # options - The Hash options is used to refine the selection ( default: {}):
      #           :order_by - The string order_by to sort by ( optional )
      #           :limit - The number of items to load ( optional )
      #           :offset - The number of items to skip ( optional )
      def self.for(commentable, options = {})
        new(commentable, options).query
      end

      # Initializes the class.
      #
      # commentable = a resource that can have comments
      # options - The Hash options is used to refine the selection ( default: {}):
      #           :order_by - The string order_by to sort by ( optional )
      #           :limit - The number of items to load ( optional )
      #           :offset - The number of items to skip ( optional )
      def initialize(commentable, options = {})
        options[:order_by] ||= "older"
        @commentable = commentable
        @options = options
      end

      # Finds the Comments for a resource that can have comments and eager
      # loads comments replies. It uses Comment's MAX_DEPTH to load a maximum
      # level of nested replies.
      def query
        scope = base_scope
                .includes(:author, :up_votes, :down_votes)

        sorted_scope = case @options[:order_by]
                       when "recent"
                         order_by_recent(scope)
                       when "best_rated"
                         order_by_best_rated(scope)
                       when "most_discussed"
                         order_by_most_discussed(scope)
                       else
                         order_by_older(scope)
                       end

        apply_limit(sorted_scope)
      end

      def total_count
        base_scope.count
      end

      def has_more?
        return false unless limited?

        total_count > offset + limit
      end

      def offset
        @options[:offset].to_i
      end

      def limit
        @options[:limit]&.to_i || default_limit
      end

      private

      def limited?
        @options[:limit].present? || @options[:offset].present?
      end

      def default_limit
        commentable.is_a?(Comment) ? DEFAULT_REPLIES_LIMIT : DEFAULT_COMMENTS_LIMIT
      end

      def apply_limit(scope)
        return scope unless limited?

        # Handle both ActiveRecord relations and arrays (from best_rated/most_discussed)
        if scope.is_a?(Array)
          scope.slice(offset, limit) || []
        else
          scope.limit(limit).offset(offset)
        end
      end

      def base_scope
        id = @options[:id]
        return Comment.where(root_commentable: commentable, id:) if id.present?

        Comment.where(commentable:)
      end

      def order_by_older(scope)
        scope.order(created_at: :asc)
      end

      def order_by_recent(scope)
        scope.order(created_at: :desc)
      end

      def order_by_best_rated(scope)
        scope.sort_by do |comment|
          comment.up_votes.size - comment.down_votes.size
        end.reverse
      end

      def order_by_most_discussed(scope)
        scope.sort_by do |comment|
          count_replies(comment)
        end.reverse
      end

      def count_replies(comment)
        if comment.comment_threads.size.positive?
          comment.comment_threads.size + comment.comment_threads.sum { |reply| count_replies(reply) }
        else
          0
        end
      end
    end
  end
end
