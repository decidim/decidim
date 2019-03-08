# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      interfaces [
        -> { Decidim::Comments::CommentableInterface }
      ]

      field :author, !Decidim::Core::AuthorInterface, "The resource author" do
        resolve lambda { |obj, _args, _ctx|
          obj.user_group || obj.author
        }
      end

      field :id, !types.ID, "The Comment's unique ID"

      field :sgid, !types.String, "The Comment's signed global id" do
        resolve lambda { |obj, _args, _ctx|
          obj.to_sgid.to_s
        }
      end

      field :body, !types.String, "The comment message"

      field :formattedBody, !types.String, "The comment message ready to display (it is expected to include HTML)", property: :formatted_body

      field :createdAt, !types.String, "The creation date of the comment" do
        resolve lambda { |obj, _args, _ctx|
          obj.created_at.iso8601
        }
      end

      field :formattedCreatedAt, !types.String, "The creation date of the comment in relative format", property: :friendly_created_at

      field :alignment, types.Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'"

      field :upVotes, !types.Int, "The number of comment's upVotes" do
        resolve lambda { |obj, _args, _ctx|
          obj.up_votes.size
        }
      end

      field :upVoted, !types.Boolean, "Check if the current user has upvoted the comment" do
        resolve lambda { |obj, _args, ctx|
          obj.up_voted_by?(ctx[:current_user])
        }
      end

      field :downVotes, !types.Int, "The number of comment's downVotes" do
        resolve lambda { |obj, _args, _ctx|
          obj.down_votes.size
        }
      end

      field :downVoted, !types.Boolean, "Check if the current user has downvoted the comment" do
        resolve lambda { |obj, _args, ctx|
          obj.down_voted_by?(ctx[:current_user])
        }
      end

      field :hasComments, !types.Boolean, "Check if the commentable has comments" do
        resolve lambda { |obj, _args, _ctx|
          obj.comment_threads.size.positive?
        }
      end

      field :alreadyReported, !types.Boolean, "Check if the current user has reported the comment" do
        resolve lambda { |obj, _args, ctx|
          obj.reported_by?(ctx[:current_user])
        }
      end

      field :userAllowedToComment, !types.Boolean, "Check if the current user can comment" do
        resolve lambda { |obj, _args, ctx|
          obj.root_commentable.commentable? && obj.root_commentable.user_allowed_to_comment?(ctx[:current_user])
        }
      end
    end
  end
end
