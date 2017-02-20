# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      interfaces [
        Decidim::Comments::CommentableInterface
      ]

      field :id, !types.ID, "The Comment's unique ID"

      field :body, !types.String, "The comment message"

      field :createdAt, !types.String, "The creation date of the comment" do
        resolve lambda { |obj, _args, _ctx|
          obj.created_at.iso8601
        }
      end

      field :author, !Decidim::AuthorInterface, "The comment's author" do
        resolve lambda { |obj, _args, _ctx|
          obj.user_group || obj.author
        }
      end

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
          obj.accepts_new_comments? && obj.comments.size.positive?
        }
      end
    end
  end
end
