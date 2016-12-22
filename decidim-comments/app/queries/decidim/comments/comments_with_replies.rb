# frozen_string_literal: true
module Decidim
  module Comments
    # A class used to find comments for a commentable resource
    class CommentsWithReplies < Rectify::Query
      attr_reader :commentable

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # commentable - a resource that can have comments
      def self.for(commentable)
        new(commentable).query
      end

      # Initializes the class.
      #
      # commentable = a resource that can have comments
      def initialize(commentable)
        @commentable = commentable
      end

      # Finds the Comments for a resource that can have comments and eager
      # loads comments replies. It uses Comment's MAX_DEPTH to load a maximum
      # level of nested replies.
      def query
        Comment
          .where(decidim_commentable_id: commentable.id)
          .where(decidim_commentable_type: commentable.class.name)
          .includes(:author, :up_votes, :down_votes)
          .includes(
            replies: [:author, :up_votes, :down_votes,
              replies: [:author, :up_votes, :down_votes,
                replies: [:author, :up_votes, :down_votes]
              ]
            ]
          )
          .order(created_at: :asc)
      end
    end
  end
end
