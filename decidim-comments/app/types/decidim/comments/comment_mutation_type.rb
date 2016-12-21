# frozen_string_literal: true
module Decidim
  module Comments
    CommentMutationType = GraphQL::ObjectType.define do
      name "CommentMutation"
      description "A comment which includes its available mutations"

      field :id, !types.ID, "The Comment's unique ID"

      field :upVote, Decidim::Comments::CommentType do
        resolve lambda { |obj, _args, ctx|
          Decidim::Comments::UpVoteComment.call(obj, ctx[:current_user]) do
            on(:ok) do |comment|
              return comment
            end
          end
        }
      end
    end
  end
end
