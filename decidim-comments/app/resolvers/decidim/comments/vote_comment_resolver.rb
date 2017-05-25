# frozen_string_literal: true

module Decidim
  module Comments
    # A GraphQL resolver to handle `upVote` and `downVote` mutations
    # It creates a vote for a comment by the current user.
    class VoteCommentResolver
      def initialize(options = { weight: 1 })
        @weight = options[:weight]
      end

      def call(obj, _args, ctx)
        Decidim::Comments::VoteComment.call(obj, ctx[:current_user], weight: @weight) do
          on(:ok) do |comment|
            return comment
          end
        end
      end
    end
  end
end
