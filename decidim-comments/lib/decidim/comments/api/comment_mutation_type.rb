# frozen_string_literal: true
module Decidim
  module Comments
    CommentMutationType = GraphQL::ObjectType.define do
      name "CommentMutation"
      description "A comment which includes its available mutations"

      field :id, !types.ID, "The Comment's unique ID"

      field :upVote, Decidim::Comments::CommentType do
        resolve VoteCommentResolver.new(weight: 1)
      end

      field :downVote, Decidim::Comments::CommentType do
        resolve VoteCommentResolver.new(weight: -1)
      end
    end
  end
end
