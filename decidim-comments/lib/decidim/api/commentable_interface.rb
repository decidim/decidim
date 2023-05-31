# frozen_string_literal: true

module Decidim
  module Comments
    # This interface represents a commentable object.
    module CommentableInterface
      include Decidim::Api::Types::BaseInterface
      description "A commentable interface"

      field :id, GraphQL::Types::ID, "The commentable's ID", null: false

      field :type, GraphQL::Types::String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`", method: :commentable_type, null: false

      field :accepts_new_comments, GraphQL::Types::Boolean, "Whether the object can have new comments or not", method: :accepts_new_comments?, null: false

      field :comments_have_alignment, GraphQL::Types::Boolean, "Whether the object comments have alignment or not", method: :comments_have_alignment?, null: false

      field :comments_have_votes, GraphQL::Types::Boolean, "Whether the object comments have votes or not", method: :comments_have_votes?, null: false

      field :comments, [Decidim::Comments::CommentType], null: false do
        argument :order_by, GraphQL::Types::String, "Order the comments", required: false
        argument :single_comment_id, GraphQL::Types::String, "ID of the single comment to look at", required: false
      end

      field :total_comments_count, GraphQL::Types::Int, description: "The number of comments in all levels this resource holds", null: false

      def comments(order_by: nil, single_comment_id: nil)
        SortedComments.for(object, order_by:, id: single_comment_id).not_hidden
      end

      def total_comments_count
        object.comments_count
      end

      field :has_comments, GraphQL::Types::Boolean, "Check if the commentable has comments", null: false

      # rubocop:disable Naming/PredicateName
      def has_comments
        object.comment_threads.not_hidden.size.positive?
      end
      # rubocop:enable Naming/PredicateName

      field :user_allowed_to_comment, GraphQL::Types::Boolean, "Check if the current user can comment", null: false

      def user_allowed_to_comment
        object.commentable? && object.user_allowed_to_comment?(context[:current_user])
      end
    end
  end
end
