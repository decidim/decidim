# frozen_string_literal: true

module Decidim
  module Comments
    class CommentMutationType < Decidim::Api::Types::BaseObject
      graphql_name "CommentMutation"
      description "A comment which includes its available mutations"

      field :down_vote, Decidim::Comments::CommentType, "The comment that is downvoted", null: true
      field :id, GraphQL::Types::ID, "The Comment's unique ID", null: false
      field :up_vote, Decidim::Comments::CommentType, "The comment that is upvoted", null: true

      def up_vote(args: {})
        VoteCommentResolver.new(weight: 1).call(object, args, context)
      end

      def down_vote(args: {})
        VoteCommentResolver.new(weight: -1).call(object, args, context)
      end
    end
  end
end
