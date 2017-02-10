# frozen_string_literal: true
module Decidim
  module Comments
    # A class used to find comments for a commentable resource
    class SortedComments < Rectify::Query
      attr_reader :commentable

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # commentable - a resource that can have comments
      # options - The Hash options is used to refine the selection ( default: {}):
      #           :order_by - The string order_by to sort by ( optional )
      def self.for(commentable, options = {})
        new(commentable, options).query
      end

      # Initializes the class.
      #
      # commentable = a resource that can have comments
      # options - The Hash options is used to refine the selection ( default: {}):
      #           :order_by - The string order_by to sort by ( optional )
      def initialize(commentable, options = {})
        options[:order_by] ||= "older"
        @commentable = commentable
        @options = options
      end

      # Finds the Comments for a resource that can have comments and eager
      # loads comments replies. It uses Comment's MAX_DEPTH to load a maximum
      # level of nested replies.
      def query
        scope = Comment
                .where(commentable: commentable)
                .includes(:author, :up_votes, :down_votes)

        scope = case @options[:order_by]
                when "older"
                  order_by_older(scope)
                when "recent"
                  order_by_recent(scope)
                when "best_rated"
                  order_by_best_rated(scope)
                when "most_discussed"
                  order_by_most_discussed(scope)
                else
                  order_by_older(scope)
                end

        scope
      end

      private

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
        if comment.comments.size.positive?
          comment.comments.size + comment.comments.map { |reply| count_replies(reply) }.sum
        else
          0
        end
      end
    end
  end
end
