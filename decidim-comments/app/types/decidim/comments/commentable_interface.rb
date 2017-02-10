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

      field :acceptsNewComments, !types.Boolean, "Wether the object can have comments or not" do
        property :accepts_new_comments?
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
          SortedComments.for(obj, order_by: args[:orderBy])
        }
      end

      field :hasComments, !types.Boolean, "Check if the commentable has comments" do
        resolve lambda { |obj, _args, _ctx|
          obj.comments.size.positive?
        }
      end
    end
  end
end
