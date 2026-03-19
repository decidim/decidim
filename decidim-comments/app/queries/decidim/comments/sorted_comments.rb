# frozen_string_literal: true

module Decidim
  module Comments
    # A class used to find comments for a commentable resource
    class SortedComments < Decidim::Query
      DEFAULT_COMMENTS_LIMIT = 20

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
      #           :alignment - Filter by alignment: 1 (in_favor), -1 (against), 0 (neutral) ( optional )
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
                .includes(:author)

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
        DEFAULT_COMMENTS_LIMIT
      end

      def apply_limit(scope)
        return scope unless limited?

        scope.limit(limit).offset(offset)
      end

      def base_scope
        id = @options[:id]
        return Comment.where(root_commentable: commentable, id:) if id.present?

        scope = Comment.where(commentable:)
        scope = scope.where(alignment: @options[:alignment]) if @options[:alignment].present?
        scope
      end

      def order_by_older(scope)
        scope.order(created_at: :asc)
      end

      def order_by_recent(scope)
        scope.order(created_at: :desc)
      end

      def order_by_best_rated(scope)
        scope.order(Arel.sql("up_votes_count - down_votes_count DESC, created_at DESC"))
      end

      def order_by_most_discussed(scope)
        scope
          .select("decidim_comments_comments.*, COALESCE(descendants.total, 0) as descendants_count")
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              WITH RECURSIVE comment_tree AS (
                SELECT id, decidim_commentable_id
                FROM decidim_comments_comments AS replies
                WHERE replies.decidim_commentable_id = decidim_comments_comments.id
                  AND replies.decidim_commentable_type = 'Decidim::Comments::Comment'

                UNION ALL

                SELECT r.id, r.decidim_commentable_id
                FROM decidim_comments_comments AS r
                INNER JOIN comment_tree ct ON r.decidim_commentable_id = ct.id
                  AND r.decidim_commentable_type = 'Decidim::Comments::Comment'
              )
              SELECT COUNT(*) as total
              FROM comment_tree
            ) descendants ON true
          SQL
          .order(Arel.sql("descendants_count DESC, decidim_comments_comments.created_at DESC"))
      end
    end
  end
end
