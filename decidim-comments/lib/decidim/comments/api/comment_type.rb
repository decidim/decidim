# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    class CommentType < Decidim::Api::Types::BaseObject
      description "A comment"

      implements Decidim::Comments::CommentableInterface
      field :author, Decidim::Core::AuthorInterface, "The resource author", null: false

      def author
        object.user_group || object.author
      end

      field :id, ID, "The Comment's unique ID", null: false

      field :sgid, String, "The Comment's signed global id", null: false
      def sgid
        object.to_sgid.to_s
      end

      field :body, String, "The comment message", null: false
      def body
        object.translated_body
      end

      field :formatted_body, String, "The comment message ready to display (it is expected to include HTML)", null: false

      field :created_at, String, "The creation date of the comment", null: false

      def created_at
        object.created_at.iso8601
      end

      field :formatted_created_at, String, "The creation date of the comment in relative format", null: false
      def formatted_created_at
        object.friendly_created_at
      end

      field :alignment, Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", null: true

      field :up_votes, Int, "The number of comment's upVotes", null: false
      def up_votes
        object.up_votes.size
      end

      field :up_voted, Boolean, "Check if the current user has upvoted the comment", null: false

      def up_voted
        object.up_voted_by?(context[:current_user])
      end

      field :down_votes, Int, "The number of comment's downVotes", null: false
      def down_votes
        object.down_votes.size
      end

      field :down_voted, Boolean, "Check if the current user has downvoted the comment", null: false

      def down_voted
        object.down_voted_by?(context[:current_user])
    end

      field :has_comments, Boolean, "Check if the commentable has comments", null: false
      def has_comments
        object.comment_threads.size.positive?
      end

      field :already_reported, Boolean, "Check if the current user has reported the comment", null: false

      def already_reported
        object.reported_by?(context[:current_user])
      end

      field :user_allowed_to_comment, Boolean, "Check if the current user can comment", null: false
      def user_allowed_to_comment
        object.root_commentable.commentable? && object.root_commentable.user_allowed_to_comment?(context[:current_user])
      end
    end
  end
end
