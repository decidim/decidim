# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    CommentType = GraphQL::ObjectType.define do
      name "Comment"
      description "A comment"

      field :id, !types.ID, "The Comment's unique ID"

      field :body, !types.String, "The comment message"

      field :createdAt, !types.String, "The creation date of the comment" do
        resolve lambda { |obj, _args, _ctx|
          obj.created_at.iso8601
        }
      end

      field :author, !AuthorType, "The comment's author"

      field :replies, !types[CommentType], "The comment's replies" do
        resolve lambda { |obj, _args, _ctx|
          obj.replies.sort_by(&:created_at)
        }
      end

      field :hasReplies, !types.Boolean, "Check if the comment has replies" do
        resolve lambda { |obj, _args, _ctx|
          obj.replies.size.positive?
        }
      end

      field :canHaveReplies, !types.Boolean, "Define if a comment can or not have replies" do
        property :can_have_replies?
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
      
    end
  end
end
