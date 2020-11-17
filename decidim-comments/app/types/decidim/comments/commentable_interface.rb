# frozen_string_literal: true

module Decidim
  module Comments
    module CommentableInterface
      include GraphQL::Schema::Interface
      # name "CommentableInterface"
      # description "A commentable interface"

      field :id, ID, null: false, description: "The commentable's ID"
      field :type, String, null: false, description: "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`"
      field :acceptsNewComments, Boolean, null: false, description: "Whether the object can have new comments or not"
      field :commentsHaveAlignment, Boolean, null: false, description: "Whether the object comments have alignment or not"
      field :commentsHaveVotes, Boolean, null: false, description: "Whether the object comments have votes or not"
      field :comments, [CommentType], null: false do
        argument :orderBy, String, required: false, description: "Order the comments"
        argument :singleCommentId, String, required: false, description: "ID of the single comment to look at"

        def resolve(object:, _args:, context:)
          SortedComments.for(object, order_by: args[:orderBy], id: args[:singleCommentId])
        end
      end
      field :totalCommentsCount, Int, null: false, description: "The number of comments in all levels this resource holds" do
        def resolve(object:, _args:, context:)
          object.comments_count
        end
      end

      field :hasComments, Boolean, null: false, description: "Check if the commentable has comments" do
        def resolve(object:, _args:, context:)
          object.comment_threads.size.positive?
        end
      end

      field :userAllowedToComment, Boolean, null: false, description: "Check if the current user can comment" do
        def resolve(object:, _args:, context:)
          object.commentable? && object.user_allowed_to_comment?(context[:current_user])
        end
      end

      def commentsHaveAlignment
        object.comments_have_alignment?
      end

      def commentsHaveVotes
        object.comments_have_votes?
      end

      def type
        object.commentable_type
      end

      def acceptsNewComments
        object.accepts_new_comments?
      end
    end
  end
end
