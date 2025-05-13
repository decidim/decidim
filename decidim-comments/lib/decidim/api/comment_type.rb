# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    class CommentType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Comments::CommentableInterface

      description "A comment"

      field :alignment, GraphQL::Types::Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", null: true
      field :already_reported, GraphQL::Types::Boolean, "Check if the current user has reported the comment", null: false
      field :author, Decidim::Core::AuthorInterface, "The resource author", null: false
      field :body, GraphQL::Types::String, "The comment message", null: false, method: :translated_body
      field :down_voted, GraphQL::Types::Boolean, "Check if the current user has downvoted the comment", null: false
      field :down_votes, GraphQL::Types::Int, "The number of comment's downVotes", null: false, method: :down_votes_count
      field :formatted_body, GraphQL::Types::String, "The comment message ready to display (it is expected to include HTML)", null: false
      field :formatted_created_at, GraphQL::Types::String, "The creation date of the comment in relative format", null: false, method: :friendly_created_at
      field :has_comments, GraphQL::Types::Boolean, "Check if the commentable has comments", method: :has_comments?, null: false
      field :id, GraphQL::Types::ID, "The Comment's unique ID", null: false
      field :sgid, GraphQL::Types::String, "The Comment's signed global id", null: false
      field :up_voted, GraphQL::Types::Boolean, "Check if the current user has upvoted the comment", null: false
      field :up_votes, GraphQL::Types::Int, "The number of comment's upVotes", null: false, method: :up_votes_count
      field :url, GraphQL::Types::String, "The URL for this meeting", null: false, method: :reported_content_url
      field :user_allowed_to_comment, GraphQL::Types::Boolean, "Check if the current user can comment", null: false

      def sgid
        object.to_sgid.to_s
      end

      def up_voted
        object.up_voted_by?(context[:current_user])
      end

      def down_voted
        object.down_voted_by?(context[:current_user])
      end

      def has_comments?
        object.comment_threads.not_hidden.size.positive?
      end

      def already_reported
        object.reported_by?(context[:current_user])
      end

      def user_allowed_to_comment
        object.root_commentable.commentable? && object.root_commentable.user_allowed_to_comment?(context[:current_user])
      end

      def self.authorized?(object, context)
        chain = []
        if object.respond_to?(:commentable) && !object.commentable.is_a?(Decidim::Comments::Comment)
          chain.unshift(allowed_to?(:read, object.commentable, object.commentable,
                                    context))
        end

        chain.unshift(!object.hidden?)
        chain.unshift(!object.deleted?)

        super && chain.all?
      end
    end
  end
end
