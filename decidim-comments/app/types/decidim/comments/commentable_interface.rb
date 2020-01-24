# frozen_string_literal: true

module Decidim
  module Comments
    # This interface represents a commentable object.
    CommentableInterface = GraphQL::InterfaceType.define do
      name "CommentableInterface"
      description "A commentable interface"

      field :id, !types.ID, "The commentable's ID"

      field :type, !types.String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`" do
        property :commentable_type
      end

      field :acceptsNewComments, !types.Boolean, "Whether the object can have new comments or not" do
        property :accepts_new_comments?
      end

      field :commentsHaveAlignment, !types.Boolean, "Whether the object comments have alignment or not" do
        property :comments_have_alignment?
      end

      field :commentsHaveVotes, !types.Boolean, "Whether the object comments have votes or not" do
        property :comments_have_votes?
      end

      field :comments do
        type !types[!CommentType]

        argument :orderBy, types.String, "Order the comments"
        argument :singleCommentId, types.String, "ID of the single comment to look at"

        resolve lambda { |obj, args, _ctx|
          SortedComments.for(obj, order_by: args[:orderBy], id: args[:singleCommentId])
        }
      end

      field :totalCommentsCount do
        type !types.Int
        description "The number of comments in all levels this resource holds"

        resolve lambda { |obj, _args, _ctx|
          obj.comments.count
        }
      end

      field :hasComments, !types.Boolean, "Check if the commentable has comments" do
        resolve lambda { |obj, _args, _ctx|
          obj.comment_threads.size.positive?
        }
      end

      field :userAllowedToComment, !types.Boolean, "Check if the current user can comment" do
        resolve lambda { |obj, _args, ctx|
          obj.commentable? && obj.user_allowed_to_comment?(ctx[:current_user])
        }
      end
    end
  end
end
