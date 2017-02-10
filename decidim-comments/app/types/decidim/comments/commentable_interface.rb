# frozen_string_literal: true
module Decidim
  module Comments
    # This interface represents a commentable object.
    AuthorInterface = GraphQL::InterfaceType.define do
      name "Commentable"
      description "A commentable object"

      field :canHaveComments, !types.Boolean, "Wether the object can have comments or not" do
        property :is_commentable?
      end

      field :commentsHaveAlignment, !types.Boolean, "Wether the object comments have alignment or not" do
        property :comments_have_alignment?
      end

      field :commentsHaveVotes, !types.Boolean, "Wether the object comments have votes or not" do
        property :comments_have_votes?
      end

      field :comments do
        type !types[CommentType]

        argument :orderBy, types.String, "Order the comments"

        resolve lambda { |obj, args, _ctx|
          CommentsWithReplies.for(obj, order_by: args[:orderBy])
        }
      end
    end
  end
end